class Docparks < ActiveRecord::Base
require 'csv'

    establish_connection "docparks"


def self.my_import(file)

  CSV.foreach(file, :headers => true) do |row|
    self.create!(row.to_hash)
  end
end
end
