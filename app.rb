require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require 'better_errors'

require './models/squad'
require './models/student'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squads_and_students')

before do 
  @conn = settings.conn
  Squad.conn = @conn
  Student.conn = @conn
end

# ROOT ROUTE

get '/' do 
  redirect '/squads'
end

# INDEX

get '/squads' do
  squads = []
  
  Squad.all.each do |squad|
      squads << squad
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
 @student_count = Student.all(params[:squad_id]).count
 @squad = Squad.select params[:squad_id]
 binding.pry
 erb :show
end

## EDIT/DELETE SQUAD FORM

get '/squads/:squad_id/edit' do 
  @squad = Squad.select params[:squad_id]
  erb :edit

end

## SHOW SQUAD STUDENTS

get '/squads/:squad_id/students' do 
  @students = Student.all params[:squad_id]
  @squad = Squad.select params[:squad_id]
  erb :show_all_students
end

## NEW STUDENT FORM

get '/squads/:squad_id/students/new' do 
  @squad = Squad.select params[:squad_id]
  erb :new_student
end

## SHOW STUDENT

get '/squads/:squad_id/students/:student_id' do 
  @student = Student.select params[:student_id]
  @squad = Squad.select params[:squad_id]
  erb :show_student
end

## EDIT/DELETE STUDENT FORM

get '/squads/:squad_id/students/:student_id/edit' do 
  @student = Student.select params[:student_id]
  @squad = Squad.select params[:squad_id]
  erb :edit_student
end

## NEW SQUAD ACTION

post '/squads' do
  Squad.create params
  redirect '/squads'
end

## NEW STUDENT

post '/squads/:squad_id/students/' do 
  Student.create params
  redirect '/squads/' << params[:squad_id] << '/students'
end

## EDIT SQUAD ACTION

put '/squads/:squad_id' do
  s = Squad.select(params[:squad_id].to_i)
  s.name = params[:name]
  s.mascot = params[:mascot]
  s.save
  
  redirect '/squads/' << params[:squad_id]
end

## EDIT STUDENT ACTION

put '/squads/:squad_id/students/:student_id' do
  stud = Student.select(params[:student_id].to_i)
  stud.name = params[:name]
  stud.age = params[:age].to_i
  stud.spirit_animal = params[:spirit_animal]
  stud.save

  redirect '/squads/' << params[:squad_id] << '/students/' << params[:student_id]
end

## DELETE SQUAD ACTION

delete '/squads/:squad_id' do
  Squad.select(params[:squad_id].to_i).destroy
  redirect '/squads'
end

## DELETE STUDENT ACTION

delete '/squads/:squad_id/students/:student_id' do
  Student.select(params[:student_id].to_i).destroy
  redirect '/squads/' << params[:squad_id] << '/students'
end
