defmodule ProyectoInmobiliaria.Property do

  use GenServer

  alias ProyectoInmobiliaria.PropertyManager
  alias ProyectoInmobiliaria.UserManager
  alias ProyectoInmobiliaria.ResultsLogger

  # =========================
  # CLIENT API
  # =========================

  def start_link(property) do

    GenServer.start_link(
      __MODULE__,
      property,
      name: via_tuple(property.id)
    )

  end

  def get_state(id) do
    GenServer.call(via_tuple(id), :get_state)
  end

  def buy(id, client_username) do
    GenServer.call(via_tuple(id), {:buy, client_username})
  end

  def rent(id, client_username) do
    GenServer.call(via_tuple(id), {:rent, client_username})
  end

  def update_state(id, new_state) do
    GenServer.call(
      via_tuple(id),
      {:update_state, new_state}
    )
  end

  # =========================
  # SERVER CALLBACKS
  # =========================

  @impl true
  def init(property) do

    state = %{
      property: property,
      owner_pid: nil
    }

    {:ok, state}

  end

  # Obtener estado
  @impl true
  def handle_call(:get_state, _from, state) do

    {:reply, state, state}

  end

  # Comprar propiedad
  @impl true
  def handle_call({:buy, client_username}, _from, state) do

    property = state.property

    if property.estado != "disponible" do

      {:reply, {:error, :not_available}, state}

    else

      updated_property = %{
        property |
        estado: "vendida"
      }

      # Persistir estado
      PropertyManager.update_property_state(
        property.id,
        "vendida"
      )

      # Actualizar puntajes
      UserManager.update_score(
        client_username,
        10
      )

      UserManager.update_score(
        property.propietario,
        15
      )

      # Registrar operación
      ResultsLogger.log_operation(%{
        cliente: client_username,
        responsable: property.propietario,
        propiedad_id: property.id,
        operacion: "compra",
        ubicacion: property.ubicacion,
        precio: property.precio,
        status: "Completada"
      })

      new_state = %{
        state |
        property: updated_property
      }

      {:reply, {:ok, updated_property}, new_state}

    end

  end

  # Arrendar propiedad
  @impl true
  def handle_call({:rent, client_username}, _from, state) do

    property = state.property

    if property.estado != "disponible" do

      {:reply, {:error, :not_available}, state}

    else

      updated_property = %{
        property |
        estado: "arrendada"
      }

      # Persistir estado
      PropertyManager.update_property_state(
        property.id,
        "arrendada"
      )

      # Actualizar puntajes
      UserManager.update_score(
        client_username,
        10
      )

      UserManager.update_score(
        property.propietario,
        15
      )

      # Registrar operación
      ResultsLogger.log_operation(%{
        cliente: client_username,
        responsable: property.propietario,
        propiedad_id: property.id,
        operacion: "arriendo",
        ubicacion: property.ubicacion,
        precio: property.precio,
        status: "Completada"
      })

      new_state = %{
        state |
        property: updated_property
      }

      {:reply, {:ok, updated_property}, new_state}

    end

  end

  # Actualizar estado manualmente
  @impl true
  def handle_call(
        {:update_state, new_state_value},
        _from,
        state
      ) do

    updated_property = %{
      state.property |
      estado: new_state_value
    }

    PropertyManager.update_property_state(
      updated_property.id,
      new_state_value
    )

    new_state = %{
      state |
      property: updated_property
    }

    {:reply, :ok, new_state}

  end

  # =========================
  # REGISTRY
  # =========================

  defp via_tuple(id) do

    {:via, Registry,
      {ProyectoInmobiliaria.PropertyRegistry, id}}

  end

end
