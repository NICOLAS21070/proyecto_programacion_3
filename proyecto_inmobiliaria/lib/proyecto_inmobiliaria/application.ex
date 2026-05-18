defmodule ProyectoInmobiliaria.Application do

  use Application

  @impl true
  def start(_type, _args) do

    children = [

      # =========================
      # 1. Registry de propiedades
      # =========================

      ProyectoInmobiliaria.PropertyRegistry,

      # =========================
      # 2. Supervisor dinámico
      # =========================

      ProyectoInmobiliaria.PropertySupervisor,

      # =========================
      # 3. Session Manager
      # =========================

      ProyectoInmobiliaria.SessionManager

      # =========================
      # 4. TCP Server
      # (FASE 3)
      # =========================

      # ProyectoInmobiliaria.Server

    ]

    opts = [
      strategy: :one_for_one,
      name: ProyectoInmobiliaria.Supervisor
    ]

    # =========================
    # Iniciar árbol OTP
    # =========================

    {:ok, pid} =
      Supervisor.start_link(children, opts)

    # =========================
    # Restaurar propiedades
    # =========================

    ProyectoInmobiliaria.PropertyManager.load_properties()
    |> Enum.reject(fn property ->

      property.estado in [
        "vendida",
        "arrendada"
      ]

    end)
    |> Enum.each(fn property ->

      ProyectoInmobiliaria.PropertySupervisor.start_property(
        property
      )

    end)

    {:ok, pid}

  end

end
