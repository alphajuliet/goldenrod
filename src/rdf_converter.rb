#!/bin/env ruby

require 'csv'
require 'rdf'
require 'rdf/turtle'

#-------------------
class RdfConverter

  attr_reader :data, :triples
  
  def initialize()
    STDERR.puts "# Running converter: #{__FILE__}"
    @triples = Array.new
  end

  def to_rdf

    # Make triples
    @triples = []
    @data.each do |row|
      s = subject(row) 
      row.each do |key, value|
        p = self.prefix + make_property(key)
        o = make_object(value)
        @triples << [s, p, o]
      end
    end

    # map_properties
    # assign_types
    # handle_invalid_values
    
    @triples
  end

  def subject(row)
    # abstract method to be implemented in the subclass
  end

  def make_property(str)
    str.sub!(/[%$()]+/, "")
    str.tr!("A-Z", "a-z")
    str.rstrip!
    str.sub!(/\s+/, "-")
    str
  end

  def prefix 

  end

  def make_object(str)
    "\"#{str}\""
  end

  #------------------------------
  def find_newest(fname)
    candidates = Dir.glob(fname)
    raise "### No files found" if candidates.size == 0
    candidates.sort.last
  end

  def load_csv(fname)
    # Create an array of rows
    @data = CSV.read(fname, :headers => true)
  end

  def load_latest(fpattern)
    load_csv(find_newest(fpattern))
  end

  #------------------------------

end

# The End
