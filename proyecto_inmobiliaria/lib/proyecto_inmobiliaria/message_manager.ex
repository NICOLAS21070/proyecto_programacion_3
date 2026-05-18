defmodule ProyectoInmobiliaria.MessageManager do

  alias ProyectoInmobiliaria.FileUtils

  # Enviar mensaje
  def send_message(property_id, sender, recipient, message) do

    timestamp =
      DateTime.utc_now()
      |> DateTime.to_iso8601()

    line =
      Enum.join([
        timestamp,
        property_id,
        sender,
        recipient,
        message
      ], ";")

    FileUtils.write_line(
      "data/messages.log",
      line
    )

  end

  # Obtener mensajes de una propiedad
  def get_messages_for_property(property_id) do

    case FileUtils.read_lines("data/messages.log") do

      {:ok, lines} ->

        lines
        |> Enum.map(fn line ->

          [
            timestamp,
            prop_id,
            sender,
            _recipient,
            message
          ] = String.split(line, ";", parts: 5)

          {
            timestamp,
            prop_id,
            sender,
            message
          }

        end)
        |> Enum.filter(fn {

          _timestamp,
          prop_id,
          _sender,
          _message

        } ->

          prop_id == property_id

        end)
        |> Enum.map(fn {

          timestamp,
          _prop_id,
          sender,
          message

        } ->

          {timestamp, sender, message}

        end)

      {:error, _reason} ->
        []

    end

  end

  # Obtener mensajes enviados por usuario
  def get_messages_sent_by(username) do

    case FileUtils.read_lines("data/messages.log") do

      {:ok, lines} ->

        lines
        |> Enum.map(fn line ->

          [
            timestamp,
            property_id,
            sender,
            recipient,
            message
          ] = String.split(line, ";", parts: 5)

          {
            timestamp,
            property_id,
            sender,
            recipient,
            message
          }

        end)
        |> Enum.filter(fn {

          _timestamp,
          _property_id,
          sender,
          _recipient,
          _message

        } ->

          sender == username

        end)
        |> Enum.map(fn {

          timestamp,
          property_id,
          _sender,
          recipient,
          message

        } ->

          {
            timestamp,
            property_id,
            recipient,
            message
          }

        end)

      {:error, _reason} ->
        []

    end

  end

end
