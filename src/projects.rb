#!/usr/bin/env ruby
# projects.rb
# aj 2014-12-05

$:.unshift File.join(File.dirname(__FILE__))

require 'digest/sha1'
require 'my_prefixes'
require 'rdf_converter'

#---------------------------------
class Projects < RdfConverter

  def initialize
    super
    STDERR.puts "# Running converter: #{__FILE__}"
    @ns = "http://alphajuliet.com/ns/rsa/proj#"
    @triples = []
  end

  def convert_to_rdf
    add_graph_metadata
    @csv.each do |row|
      s = make_subject(row) 
      # STDERR.puts "# subject: #{s}"
      @triples << [s, RDF.type, RDF::PROJ.Project]
      row.each do |key, value|
        p = make_property(key)
        o = make_object(value)
        @triples << [s, p, o] unless o.nil?
      end
    end
    return self 
  end

  def make_subject(row)
    id = Digest::SHA1.hexdigest(row['FN'])[-8..-1] if row.header?('FN')
    id = Digest::SHA1.hexdigest(row['fn'])[-8..-1] if row.header?('fn')
    raise "# Error: id empty" if id.nil?
    RDF::Resource.new(RDF::PROJ["p"+id])
  end

  def make_property(str)
    p = self.clean(str)
    RDF::Resource.new(RDF::PROJ[p])
  end

  def make_object(str)
    return nil if str.nil?
    str.gsub!(/%/,'')
    str.gsub!(/[$,]/, '')
    x = RDF::Literal.new(str.to_s)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.integer) if (str =~ /^[0-9]+$/)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.decimal) if (str =~ /^[0-9]+\.[0-9]*$/)
    x = RDF::Literal.new("false", :datatype => RDF::XSD.boolean) if (str =~ /no|false/i)
    x = RDF::Literal.new("true", :datatype => RDF::XSD.boolean) if (str =~ /yes|true/i)
    if (str =~ /^[0-9]{2}-[0-9]{2}-[0-9]{2}$/)
      d = Date.strptime(str, "%d-%m-%y")
      x = RDF::Literal.new(d.to_s, :datatype => RDF::XSD.date) 
    end
    if (str =~ /^\w{3}-\d{2}/)
      d = Date.strptime(str, "%b-%y")
      x = RDF::Literal.new(d.to_s, :datatype => RDF::XSD.date) 
    end
    x
  end

  def add_graph_metadata
    dt = DateTime.now
    this = RDF::URI.new(@name)
    @triples << [ this, RDF.type, RDF::PROJ.Snapshot ]
    @triples << [ this, RDF::RDFS.label, RDF::Literal.new("A graph containing a snapshot of the projects.") ]
    @triples << [ this, RDF::DCT.title, RDF::Literal.new("proj " + @datestamp) ]
    @triples << [ this, RDF::DCT.created, RDF::Literal.new(dt.to_s, :datatype => RDF::XSD.datetime)]
    @triples << [ this, RDF::DC.date, RDF::Literal.new(@datestamp, :datatype => RDF::XSD.date) ]
  end

  def to_turtle
    @graph = RDF::Graph.new(:context => @name)
    @triples.each { |t| @graph << t }
    # @graph.dump(:turtle, :prefixes => RDF::PREFIX)
  end

  def write_as_turtle(filename)
    raise "Empty graph" if @graph.nil?
    RDF::Turtle::Writer.open(filename, :prefixes => RDF::PREFIX) do |writer|
      writer << @graph
    end
  end

end

#---------------------------------
if __FILE__ == $0

  if ARGV.length == 1
    p = Projects.new
    p.load_csv(ARGV[0])
    p.convert_to_rdf
    p.to_turtle
    puts p.graph.dump(:turtle, :prefixes => RDF::PREFIX)
  end

end

# The End
