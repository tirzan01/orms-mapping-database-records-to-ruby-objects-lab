class Student
  attr_accessor :name, :grade, :id

  def initialize(name=nil, grade=nil, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def id=(new_id)
    @id = new_id
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new(row[1], row[2], row[0])
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL

    student = DB[:conn].execute(sql, name).first
    self.new_from_db(student)
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
    SELECT * FROM students
    SQL

    students = DB[:conn].execute(sql)
    students.map { |row| new_from_db(row)}
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    new_guy = DB[:conn].execute(sql, name).first
    new_from_db(new_guy)
  end

  def self.all_students_in_grade_9
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 9
    SQL

    students_from_9_grade = DB[:conn].execute(sql)
    students_from_9_grade.map { |row| new_from_db(row) }
  end

  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT * FROM students WHERE grade < 12
    SQL

    students_with_grade_below_12 = DB[:conn].execute(sql)
    students_with_grade_below_12.map { |row| new_from_db(row) }
  end

  def self.first_X_students_in_grade_10(limit)
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 10 LIMIT ?
    SQL

    x_students_in_grade_10 = DB[:conn].execute(sql, limit)
    x_students_in_grade_10.map { |row| new_from_db(row) }
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT * FROM students WHERE grade = 10 ORDER BY id LIMIT 1
    SQL

    first_students_in_grade_10 = DB[:conn].execute(sql).first
    new_from_db(first_students_in_grade_10)
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
      SELECT * FROM students WHERE grade = ?
    SQL

    all_student_from_x_grade = DB[:conn].execute(sql, grade)
    all_student_from_x_grade.map { |row| new_from_db(row) }
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    sql2 = <<-SQL
    SELECT last_insert_rowid()
    SQL

    @id =  DB[:conn].execute(sql2)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
