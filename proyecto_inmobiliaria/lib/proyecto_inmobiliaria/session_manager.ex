defmodule ProyectoInmobiliaria.SessionManager do

  use GenServer

  alias ProyectoInmobiliaria.UserManager

  # =========================
  # CLIENT API
  # =========================

  def start_link(opts \\ []) do

    GenServer.start_link(
      __MODULE__,
      opts,
      name: __MODULE__
    )

  end

  def connect(username, password, pid) do

    GenServer.call(
      __MODULE__,
      {:connect, username, password, pid}
    )

  end

  def disconnect(username) do

    GenServer.call(
      __MODULE__,
      {:disconnect, username}
    )

  end

  def list_sessions do
    GenServer.call(__MODULE__, :list_sessions)
  end

  def get_session(username) do

    GenServer.call(
      __MODULE__,
      {:get_session, username}
    )

  end

  def is_connected?(username) do

    GenServer.call(
      __MODULE__,
      {:is_connected?, username}
    )

  end

  # =========================
  # SERVER CALLBACKS
  # =========================

  @impl true
  def init(_opts) do

    state = %{
      sessions: %{}
    }

    {:ok, state}

  end

  # =========================
  # CONECTAR USUARIO
  # =========================

  @impl true
  def handle_call(
        {:connect, username, password, pid},
        _from,
        state
      ) do

    result =
      case UserManager.authenticate(username, password) do

        {:ok, user} ->

          {:ok, user}

        {:error, :not_found} ->

          # Registro automático
          UserManager.register_user(
            username,
            "cliente",
            password
          )

          UserManager.authenticate(
            username,
            password
          )

        {:error, reason} ->

          {:error, reason}

      end

    case result do

      {:ok, user} ->

        session_data = %{
          rol: user.rol,
          pid: pid,
          connected_at: DateTime.utc_now()
        }

        new_sessions =
          Map.put(
            state.sessions,
            username,
            session_data
          )

        new_state = %{
          state |
          sessions: new_sessions
        }

        {:reply, {:ok, user}, new_state}

      {:error, reason} ->

        {:reply, {:error, reason}, state}

    end

  end

  # =========================
  # DESCONECTAR
  # =========================

  @impl true
  def handle_call(
        {:disconnect, username},
        _from,
        state
      ) do

    if Map.has_key?(state.sessions, username) do

      new_sessions =
        Map.delete(state.sessions, username)

      new_state = %{
        state |
        sessions: new_sessions
      }

      {:reply, :ok, new_state}

    else

      {:reply, {:error, :not_connected}, state}

    end

  end

  # =========================
  # LISTAR SESIONES
  # =========================

  @impl true
  def handle_call(
        :list_sessions,
        _from,
        state
      ) do

    {:reply, state.sessions, state}

  end

  # =========================
  # OBTENER SESIÓN
  # =========================

  @impl true
  def handle_call(
        {:get_session, username},
        _from,
        state
      ) do

    session =
      Map.get(state.sessions, username)

    if session do
      {:reply, {:ok, session}, state}
    else
      {:reply, {:error, :not_found}, state}
    end

  end

  # =========================
  # VERIFICAR CONEXIÓN
  # =========================

  @impl true
  def handle_call(
        {:is_connected?, username},
        _from,
        state
      ) do

    result =
      Map.has_key?(
        state.sessions,
        username
      )

    {:reply, result, state}

  end

end
