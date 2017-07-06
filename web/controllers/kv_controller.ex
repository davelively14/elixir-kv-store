defmodule ElixirKvStore.KVController do
  use ElixirKvStore.Web, :controller
  alias ElixirKvStore.Store

  def index(conn, _params) do
    keys = Store.keys()
    json conn, keys
  end

  def get(conn, params=%{"key" => key}) do
    result = Store.fetch(key)
    json conn, result
  end

  def add(conn, params=%{"key" => key, "value" => value, "exp" => exp}) do
    result = Store.set(key, value, exp)
    json conn, result
  end

  def add(conn, params=%{"key" => key, "value" => value}) do
    result = Store.set(key, value)
    json conn, result
  end

  def delete(conn, params=%{"key" => key}) do
    result = Store.delete(key)
    json conn, result
  end

  def get_timeout(conn, params=%{"key" => key}) do
    result = Store.get_timeout(key)
    json conn, result
  end
end
