#!/bin/env ruby

require 'date'
require 'csv'
require 'rdf'
require 'rdf/turtle'
require 'my_prefixes'

#-------------------
class RdfConverter

  attr_reader :data, :triples, :graph, :name, :datestamp
  
  def initialize
  end

  def convert_to_rdf
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
    @datestamp = Date.today.to_s
    @csv = CSV.read(fname, :headers => true)

    d = fname.match(/\d{4}-\d{2}-\d{2}/)
    @datestamp = d.to_s unless d.nil?

    @name = @ns + @datestamp
    STDERR.puts "# Datestamp: #{@datestamp}"
  end

  def load_latest(fpattern)
    load_csv(find_newest(fpattern))
  end

  # Utility function
  def clean(str)
    s = str
    s.gsub!('%', 'percent')
    s.gsub!('?', '_q')
    s.gsub!(/[$()\/]+/, "")
    s.tr!("A-Z", "a-z")
    s.rstrip!
    s.gsub!(/\s+/, "-")
    s
  end

  #------------------------------

end

# The End
