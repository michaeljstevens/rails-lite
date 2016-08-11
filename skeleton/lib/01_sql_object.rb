require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    @columns[0].map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) { self.attributes[column] }
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    all_hash = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    self.parse_all(all_hash)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    output = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL
    parse_all(output).first
  end

  def initialize(params = {})
    params.each do |k, v|
      attr_name = k.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name)
      self.send("#{attr_name}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = []
    self.class.columns.size.times { question_marks << "?" }

    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO  #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks.join(",")})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col)}
  end

  def update
    col_names = self.class.columns.map { |col| "#{col} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, attribute_values, self.id)
      UPDATE #{self.class.table_name}
      SET #{col_names}
      WHERE id = ?
    SQL

  end

  def save
    id.nil? ? insert : update
  end
end
