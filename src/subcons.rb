#!/usr/bin/env ruby
# subcon.rb
# aj 2014-12-16

$:.unshift File.join(File.dirname(__FILE__))

require 'rdf_converter'

#---------------------------------
class Subcons < RdfConverter

  def initialize
    super
    STDERR.puts "# Running converter: #{__FILE__}"
    @ns = "http://alphajuliet.com/ns/rsa/subcon#"
    @triples = []
  end

  def convert_to_rdf
    add_graph_metadata
    @csv.each do |row|
      s = make_subject(row) 
      # STDERR.puts "# subject: #{s}"
      @triples << [s, RDF.type, RDF::SUBCON.Subcontractor]
      row.each do |key, value|
        p = make_property(key)
        o = make_object(value)
        @triples << [s, p, o] unless o.nil?
      end
    end
    return self 
  end

  def make_subject(row)
    # Subject is a blank node
    RDF::Node.new()
  end

  def make_property(str)
    p = self.clean(str)
    RDF::Resource.new(RDF::SUBCON[p])
  end

  def make_object(str)
    x = RDF::Literal.new(str.to_s)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.integer) if (str =~ /^[0-9]+$/)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.decimal) if (str =~ /^[0-9]+\.[0-9]*$/)
    if (str =~ /^[0-9]{2}-[0-9]{2}-[0-9]{2}$/)
      d = Date.strptime(str, "%d-%m-%y")
      x = RDF::Literal.new(d.to_s, :datatype => RDF::XSD.date) 
    end
    x
  end

  def add_graph_metadata
    dt = DateTime.now
    this = RDF::URI.new(@name)
    @triples << [ this, RDF.type, RDF::SUBCON.Snapshot ]
    @triples << [ this, RDF::RDFS.label, RDF::Literal.new("A graph containing a snapshot of the subcon POs.") ]
    @triples << [ this, RDF::DCT.title, RDF::Literal.new("subcons-" + @datestamp) ]
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
    p = Subcons.new
    p.load_csv(ARGV[0])
    p.convert_to_rdf
    # puts p.triples
    puts p.to_turtle
  end

end

# The End
