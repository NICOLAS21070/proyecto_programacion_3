defmodule ProyectoInmobiliaria.UserManager do

  alias ProyectoInmobiliaria.FileUtils

  defstruct [:username, :rol, :password, :puntaje]

  # Convertir línea del archivo a struct
  def parse_user(line) do

    [username, rol, password, puntaje] =
      String.split(line, ";")

    %__MODULE__{
      username: username,
      rol: rol,
      password: password,
      puntaje: String.to_integer(puntaje)
    }

  end

  # Convertir struct a línea de texto
  def serialize_user(user) do

    "#{user.username};#{user.rol};#{user.password};#{user.puntaje}"

  end

  # Cargar todos los usuarios
  def load_users do

    case FileUtils.read_lines("data/users.dat") do

      {:ok, lines} ->
        Enum.map(lines, &parse_user/1)

      {:error, _reason} ->
        []

    end

  end

  # Buscar usuario por username
  def find_user(username) do

    user =
      load_users()
      |> Enum.find(fn user ->
        user.username == username
      end)

    if user do
      {:ok, user}
    else
      {:error, :not_found}
    end

  end

  # Registrar nuevo usuario
  def register_user(username, rol, password) do

    case find_user(username) do

      {:ok, _user} ->
        {:error, :already_exists}

      {:error, :not_found} ->

        new_user = %__MODULE__{
          username: username,
          rol: rol,
          password: password,
          puntaje: 0
        }

        FileUtils.write_line(
          "data/users.dat",
          serialize_user(new_user)
        )

    end

  end

  # Autenticar usuario
  def authenticate(username, password) do

    case find_user(username) do

      {:ok, user} ->

        if user.password == password do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      {:error, :not_found} ->
        {:error, :not_found}

    end

  end

  # Actualizar puntaje
  def update_score(username, points) do

    updated_users =
      load_users()
      |> Enum.map(fn user ->

        if user.username == username do

          %{user | puntaje: user.puntaje + points}

        else
          user
        end

      end)

    updated_users
    |> Enum.map(&serialize_user/1)
    |> then(fn lines ->
      FileUtils.overwrite_lines(
        "data/users.dat",
        lines
      )
    end)

  end

  # Obtener ranking
  def get_ranking do

    load_users()
    |> Enum.sort_by(fn user ->
      user.puntaje
    end, :desc)
    |> Enum.map(fn user ->
      {user.username, user.rol, user.puntaje}
    end)

  end

end
