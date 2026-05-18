defmodule ProyectoInmobiliaria.PropertySupervisor do

  use DynamicSupervisor

  alias ProyectoInmobiliaria.Property

  # =========================
  # INICIO DEL SUPERVISOR
  # =========================

  def start_link(opts \\ []) do

    DynamicSupervisor.start_link(
      __MODULE__,
      opts,
      name: __MODULE__
    )

  end

  # =========================
  # CALLBACK INIT
  # =========================

  @impl true
  def init(_opts) do

    DynamicSupervisor.init(
      strategy: :one_for_one
    )

  end

  # =========================
  # INICIAR PROPIEDAD
  # =========================

  def start_property(property) do

    DynamicSupervisor.start_child(
      __MODULE__,
      {Property, property}
    )

  end

  # =========================
  # DETENER PROPIEDAD
  # =========================

  def stop_property(id) do

    case Registry.lookup(
      ProyectoInmobiliaria.PropertyRegistry,
      id
    ) do

      [{pid, _value}] ->

        DynamicSupervisor.terminate_child(
          __MODULE__,
          pid
        )

      [] ->
        {:error, :not_found}

    end

  end

  # =========================
  # LISTAR PROPIEDADES ACTIVAS
  # =========================

  def list_active_properties do

    Registry.select(
      ProyectoInmobiliaria.PropertyRegistry,
      [
        {
          {:"$1", :_, :_},
          [],
          [:"$1"]
        }
      ]
    )

  end

end
