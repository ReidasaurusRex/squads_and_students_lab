require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require 'better_errors'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squads_and_students')

before do 
  @conn = settings.conn
end

# ROOT ROUTE

get '/' do 
  redirect '/squads'
end

# INDEX

get '/squads' do
  squads = []
  
  @conn.exec("SELECT * FROM squads_table ORDER BY id ASC") do |result|
    result.each do |squad|
      squads << squad
    end
  end
  @squads = squads
  erb :index
end

## NEW SQUAD FORM

get '/squads/new' do 
erb :new
end

## SHOW SQUAD

get '/squads/:squad_id' do 
 student_count = @conn.exec("SELECT COUNT(*) FROM students_table WHERE squad_id = $1", [params[:squad_id].to_i])
 @student_count = student_count[0]['count']
 squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id]])
 @squad = squad[0]
 erb :show
end

## EDIT/DELETE SQUAD FORM

get '/squads/:squad_id/edit' do 
  squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id].to_i])
  @squad = squad[0]
  binding.pry
  erb :edit

end

## SHOW SQUAD STUDENTS

get '/squads/:squad_id/students' do 
  students = []
  @conn.exec("SELECT * FROM students_table WHERE squad_id = $1 ORDER BY id ASC", [params[:squad_id].to_i]) do |result|
    result.each do |student|
      students << student
    end
  end
  @students = students
  
  squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id].to_i])
  @squad = squad[0]

  erb :show_all_students
end

## NEW STUDENT FORM

get '/squads/:squad_id/students/new' do 
  squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id].to_i])
  @squad = squad[0]

  erb :new_student
end

## SHOW STUDENT

get '/squads/:squad_id/students/:student_id' do 
  target_student = @conn.exec("SELECT * FROM students_table WHERE id = $1", [params[:student_id].to_i])
  @student = target_student[0]

  squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id].to_i])
  @squad = squad[0]
  erb :show_student
end

## EDIT/DELETE STUDENT FORM

get '/squads/:squad_id/students/:student_id/edit' do 
  target_student = @conn.exec("SELECT * FROM students_table WHERE id = $1", [params[:student_id].to_i])
  @student = target_student[0]

  squad = @conn.exec("SELECT * FROM squads_table WHERE id = $1", [params[:squad_id].to_i])
  @squad = squad[0]
  erb :edit_student
end

## NEW SQUAD ACTION

post '/squads' do
  @conn.exec("INSERT INTO squads_table (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])
  
  redirect '/squads'
end

## NEW STUDENT

post '/squads/:squad_id/students/' do 
  @conn.exec("INSERT INTO students_table (squad_id, name, age, spirit_animal) VALUES ($1, $2, $3, $4)", [params[:squad_id].to_i, params[:name], params[:age].to_i, params[:spirit_animal]])
  
  redirect '/squads/' << params[:squad_id] << '/students'
end

## EDIT SQUAD ACTION

put '/squads/:squad_id' do
  @conn.exec("UPDATE squads_table SET name=$1, mascot=$2 WHERE id=$3", [params[:name], params[:mascot], params[:squad_id].to_i])
  
  redirect '/squads/' << params[:squad_id]
end

## EDIT STUDENT ACTION

put '/squads/:squad_id/students/:student_id' do
  name = params[:name]
  age = params[:age].to_i
  spirit_animal = params[:spirit_animal]
  student_id = params[:student_id].to_i
  @conn.exec("UPDATE students_table SET name=$1, age=$2, spirit_animal=$3 WHERE id=$4", [name, age, spirit_animal, student_id])

  redirect '/squads/' << params[:squad_id] << '/students/' << params[:student_id]
end

## DELETE SQUAD ACTION

delete '/squads/:squad_id' do
  student_count = @conn.exec("SELECT COUNT(*) FROM students_table WHERE squad_id = $1", [params[:squad_id].to_i])

  @conn.exec("DELETE FROM squads_table WHERE id=$1", [params[:squad_id].to_i])

  redirect '/squads'
end

## DELETE STUDENT ACTION

delete '/squads/:squad_id/students/:student_id' do
  @conn.exec("DELETE FROM students_table WHERE id=$1", [params[:student_id].to_i])

  redirect '/squads/' << params[:squad_id]
end
