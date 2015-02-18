class Squad
  attr_reader :id
  attr_accessor :name, :mascot

  def initialize params, existing=false
    @id = params['id']
    @name = params['name']
    @mascot = params['mascot']
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

  def self.all
    @conn.exec("SELECT * FROM squads_table ORDER BY id ASC")
  end

  def self.select id
    new @conn.exec("SELECT * FROM squads_table WHERE id = $1", [id])[0], true
  end

  def students
    Squad.conn.exec("SELECT * FROM students_table WHERE squad_id = $1 ORDER BY id ASC", [id])
  end

  def save
    if existing?
      Squad.conn.exec("UPDATE squads_table SET name=$1, mascot=$2 WHERE id=$3", [name, mascot, id])
    else
      Squad.conn.exec("INSERT INTO squads_table (name, mascot) VALUES ($1, $2)", [name, mascot])
    end
  end

  def self.create params
    new(params).save
  end

  def destroy
    # Squad.conn.exec("DELETE FROM students_table WHERE id=$1", [id])
    Squad.conn.exec("DELETE FROM squads_table WHERE id=$1", [id])
  end
end