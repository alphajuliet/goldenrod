#!/usr/bin/env ruby
# pipeline.rb
# aj 2014-11-26

$:.unshift "."

require 'rdf_converter'

class Pipeline < RdfConverter

  def initialize
    super
  end

  def subject(row)
    row['Account ID']
  end

  def prefix 
    return "sfdc:"
  end

end


# The End
