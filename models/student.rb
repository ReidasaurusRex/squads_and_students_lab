class Student
  attr_reader :id
  attr_accessor :name, :age, :spirit_animal, :squad_id

  def initialize params, existing=false
    @id = params['id']
    @squad_id = params['squad_id']
    @name = params['name']
    @age = params['age']
    @spirit_animal = params['spirit_animal']
    @existing = existing
  end

  def existing? 
    @existing
  end

  def self.conn= connection
    @conn = connection
  end

  def self.conn
    @conn
  end

  def self.all id
    Squad.select(id).students
  end

  def self.select id
    new @conn.exec("SELECT * FROM students_table WHERE id = $1", [id])[0], true
  end

  def save
    if existing?
      Student.conn.exec("UPDATE students_table SET name=$1, age=$2, spirit_animal=$3 WHERE id=$4", [name, age, spirit_animal, id])
    else
      Student.conn.exec("INSERT INTO students_table (squad_id, name, age, spirit_animal) VALUES ($1, $2, $3, $4)", [squad_id, name, age.to_i, spirit_animal])
    end
  end

  def self.create params
    new(params).save
  end

  def destroy
    Student.conn.exec("DELETE FROM students_table WHERE id=$1", [id])
  end
end