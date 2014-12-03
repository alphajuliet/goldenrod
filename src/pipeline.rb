#!/usr/bin/env ruby
# pipeline.rb
# aj 2014-11-26

$:.unshift File.join(File.dirname(__FILE__))

require 'rdf_converter'

#---------------------------------
class Pipeline < RdfConverter

  def initialize
    super
    @ns = "http://alphajuliet.com/ns/rsa/sfdc/"
    @triples = []
  end

  def convert_to_rdf
    add_metadata
    @csv.each do |row|
      s = make_subject(row) 
      STDERR.puts "# subject: #{s}"
      @triples << [s, RDF.type, RDF::SFDC.opportunity]
      row.each do |key, value|
        p = make_property(key)
        o = make_object(value)
        @triples << [s, p, o] unless o.nil?
      end
    end
    return self 
  end

  def make_subject(row)
    # raise "# Error: no account ID header" unless row.header?('Opportunity ID')
    id = row['Opportunity ID'] if row.header?('Opportunity ID')
    id = row['opportunity-id'] if row.header?('opportunity-id')
    raise "# Error: id empty" if id.nil?
    RDF::Resource.new(RDF::SFDC[id])
  end

  def make_property(str)
    p = self.clean(str)
    RDF::Resource.new(RDF::SFDC[p])
  end

  def make_object(str)
    x = RDF::Literal.new(str.to_s)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.integer) if (str =~ /^[0-9]+$/)
    x = RDF::Literal.new(str, :datatype => RDF::XSD.float) if (str =~ /^[0-9]+\.[0-9]*$/)
    if (str =~ /^[0-9]{2}-[0-9]{2}-[0-9]{2}$/)
      d = Date.strptime(str, "%d-%m-%y")
      x = RDF::Literal.new(d.to_s, :datatype => RDF::XSD.date) 
    end
    x
  end

  def add_metadata
    dt = DateTime.now
    this = RDF::URI.new(@name)
    @triples << [ this, RDF::DCT.title, RDF::Literal.new("sfdc " + @datestamp) ]
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
    p = Pipeline.new
    p.load_csv(ARGV[0])
    p.convert_to_rdf
    # puts p.triples
    puts p.to_turtle
  end

end

# The End
