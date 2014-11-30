#!/bin/env ruby

require 'csv'
require 'rdf'
require 'rdf/turtle'
require 'my_prefixes'

#-------------------
class RdfConverter

  attr_reader :data, :triples, :graph
  
  def initialize
    STDERR.puts "# Running converter: #{__FILE__}"
  end

  def convert_to_rdf
  end

  def to_turtle
    @triples.each { |t| @graph << t }
    @graph.dump(:turtle, :prefixes => RDF::PREFIX)
  end

  def make_subject(row)
  end

  def make_property(str)
  end

  def make_object(str)
  end

  #------------------------------
  def find_newest(fname)
    candidates = Dir.glob(fname)
    raise "### No files found" if candidates.size == 0
    candidates.sort.last
  end

  def load_csv(fname)
    @csv = CSV.read(fname, :headers => true)
  end

  def load_latest(fpattern)
    load_csv(find_newest(fpattern))
  end

  # Utility function
  def clean(str)
    s = str
    s.gsub!(/[%$()]+/, "")
    s.tr!("A-Z", "a-z")
    s.rstrip!
    s.gsub!(/\s+/, "-")
    s
  end

  #------------------------------

end

# The End
