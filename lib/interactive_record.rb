require_relative "../config/environment.rb"
require 'active_support/inflector'

require 'pry'

class InteractiveRecord

  def initialize(students={})
    students.each do |property, value|
      self.send("#{property}=", value)
    end
  end


  def save
    row = DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")

    # sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    # DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end


  def self.table_name
    self.to_s.downcase.pluralize
  end


  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("pragma table_info('#{table_name}')")
    # sql = "pragma table_info('#{table_name}')"
    # table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each { |row| column_names << row["name"] }
    column_names.compact
  end


  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
    # sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    # DB[:conn].execute(sql)
  end


  def self.find_by(name)
    sql = "SELECT * FROM #{self.find_by_name(name)}"
    DB[:conn].execute(sql)

  end
#   it 'executes the SQL to find a row by the attribute passed into the method' do
#     Student.new({name: "Susan", grade: 10}).save
#     expect(Student.find_by({name: "Susan"})).to eq([{"id"=>1, "name"=>"Susan", "grade"=>10, 0=>1, 1=>"Susan", 2=>10}])
#   end
#
#   it 'accounts for when an attribute value is an integer' do
#     Student.new({name: "Susan", grade: 10}).save
#     Student.new({name: "Geraldine", grade: 9}).save
#     expect(Student.find_by({grade: 10})).to eq([{"id"=>1, "name"=>"Susan", "grade"=>10, 0=>1, 1=>"Susan", 2=>10}])
#   end
# end
# end

  def table_name_for_insert
    self.class.table_name
  end


  def col_names_for_insert
     self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end


  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

end
