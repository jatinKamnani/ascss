module CourseStudentHelper

  def create_entry(course, username)
    course_student = CourseStudent.find_by course: course, username: username
    if course_student
      return course_student
    end

    course_student = CourseStudent.new
    student = User.find_by_username(username)
    course_student.course = course
    course_student.username = username
    if student
      course_student.user = student
    else
      course_student.user = @user
    end

    if course_student.save
      course_student
    else
      nil
    end

  end

  def correct_entries(user)
    records = CourseStudent.where username: user.username
    records.each do |record|
      record.user = user
      record.save
    end
  end
end