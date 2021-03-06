defmodule ElixirKvStore.KVControllerTest do
  use ElixirKvStore.ConnCase
  require Logger

  setup do
    ElixirKvStore.Store.clear()
    :ok
  end

  test "GET /api/get", %{conn: conn} do
    ElixirKvStore.Store.set("test_key", "test_val")

    conn = get conn, "/api/get"
    assert json_response(conn, 200) == ["test_key"]
  end

  test "GET /api/get/:key", %{conn: conn} do
    key = "test_key1"
    val = "test_val"
    ElixirKvStore.Store.set(key, val)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val
  end

  test "POST /api/add?key=key&value=value&exp=exp", %{conn: conn} do
    key = "test_key1"
    val = "test_val"
    exp = 100
    # ElixirKvStore.Store.set(key, val, exp)
    conn = post conn, "/api/add?key=#{key}&value=#{val}&exp=#{exp}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val

    Process.sleep(200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == nil
  end

  test "POST /api/add?key=key&value=value&exp=exp reset timer no exp", %{conn: conn} do
    key = "test_key1"
    val = "test_val"
    exp = 100
    # ElixirKvStore.Store.set(key, val, exp)
    conn = post conn, "/api/add?key=#{key}&value=#{val}&exp=#{exp}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val

    conn = post conn, "/api/add?key=#{key}&value=#{val}"
    assert json_response(conn, 200)

    Process.sleep(200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val
  end

  test "POST /api/add?key=key&value=value&exp=exp reset timer with exp", %{conn: conn} do
    key = "test_key1"
    val = "test_val"
    exp = 100
    # ElixirKvStore.Store.set(key, val, exp)
    conn = post conn, "/api/add?key=#{key}&value=#{val}&exp=#{exp}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val

    conn = post conn, "/api/add?key=#{key}&value=#{val}&exp=#{300}"
    assert json_response(conn, 200)

    Process.sleep(200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val

    Process.sleep(200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == nil
  end

  test "GET /api/get_timeout?key=key", %{conn: conn} do
    key = "test_key1"
    val = "test_val"
    exp = 200

    conn = post conn, "/api/add?key=#{key}&value=#{val}&exp=#{exp}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get_timeout?key=#{key}"
    result = json_response(conn, 200)
    assert result > 0

    Process.sleep(200)

    conn = get conn, "/api/get_timeout?key=#{key}"
    result = json_response(conn, 200)
    assert result == nil
  end

  test "POST /api/add?key=key&value=value", %{conn: conn} do
    key = "test_key2"
    val = "test_val"

    conn = post conn, "/api/add?key=#{key}&value=#{val}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == val
  end


  test "POST /api/add?key=key&value=value UPDATE KEY", %{conn: conn} do
    key = "test_key2"
    val = "test_val"

    conn = post conn, "/api/add?key=#{key}&value=#{val}"
    assert json_response(conn, 200)

    new_val = "test_val2"

    conn = post conn, "/api/add?key=#{key}&value=#{new_val}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == new_val
  end

  test "POST /api/delete?key=key", %{conn: conn} do
    key = "test_key2"
    val = "test_val"

    conn = post conn, "/api/add?key=#{key}&value=#{val}"
    assert json_response(conn, 200)

    conn = post conn, "/api/delete/#{key}"
    assert json_response(conn, 200)

    conn = get conn, "/api/get/#{key}"
    assert json_response(conn, 200) == nil
  end


end
