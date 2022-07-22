require 'pg'

class SessionPersistance
  attr_reader :all_lists
  attr_accessor :error, :success

  def initialize(session)
    @session = session
    @session[:lists] ||= []
    @all_lists = @session[:lists]
  end

  def find_list(id)
    @all_lists.find { |list| list[:id] == id }
  end

  def add_list(list_hsh)
    @all_lists << list_hsh
  end

  def add_todo(list_id, text)
    list = find_list(list_id)
    todo_id = next_element_id(list[:todos])
    list[:todos] << { id: todo_id, name: text, completed: false }
  end

  def create_new_list(list_name)
    id = next_element_id(@all_lists)
    @all_lists << {id: id, name:list_name, todos: []}
  end

  def delete_list(id)
    @all_lists.reject! { |list| list[:id] == id }
  end

  def mark_all_todos_complete(id)
    list = find_list(id)

    list[:todos].each do |todo|
      todo[:completed] = true
    end
  end

  def change_todo_status(list_id, todo_id, is_completed)
    #@storage.toggle_todo_status(@list_id, todo_id)

    list = find_list(list_id)
    todo = list[:todos].find { |todo| todo[:id] == todo_id }
    todo[:completed] = is_completed
  end

  def reset_error
    @error = nil
  end

  def reset_success
    @success = nil
  end

  def delete_todo_from_list(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  private

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end