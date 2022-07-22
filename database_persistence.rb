require 'pg'

class DatabasePersistance

  def initialize(logger)
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "todos")
    end

    @logger = logger
  end

  def disconnect
    @db.close
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)

    todos = todos_from_list(id)

    tuple = result.first
    { id: tuple['id'], name: tuple['name'], todos: todos }
  end

  def query(sql, *params)
    @logger.info("#{sql}: #{params}")
    @db.exec_params(sql, params)
  end

  def todos_from_list(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"
    todos_search = query(sql, list_id)

    todos_search.map do |tuple|
      id = tuple['id']
      name = tuple['name']
      completed = tuple['completed'] == 't'

      { id: id, name: name, completed: completed }
    end
  end

  def all_lists
    sql = 'SELECT * FROM lists'
    result = query(sql)

    # array of hashes
    result.map do |tuple|
      todos = todos_from_list(tuple['id'])

      { id: tuple['id'], name: tuple['name'], todos: todos }
    end
  end

  def add_todo(list_id, name)
    sql = 'INSERT INTO todos(list_id, name) VALUES($1, $2)'

    @db.exec_params(sql, [list_id, name])
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists(name) VALUES($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def mark_all_todos_complete(id)
    sql = "UPDATE todos SET completed = true WHERE id = $1"
    query(sql, id)
  end

  def change_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, id)
  end

  def change_todo_status(list_id, todo_id, is_completed)
    # depends if todo id is still tied to list_id? list/4/todo/5923 list/5/todo/5924
    # implement for non-hierarchical/unconstrained ID

    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, is_completed.to_s, todo_id, list_id)
  end

  def delete_todo_from_list(list_id, todo_id)
    # implementation for non-hierarchical id
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
  end
end