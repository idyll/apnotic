require 'spec_helper'

describe "Triggering timeouts" do
  let(:port) { 9516 }
  let(:server) { Apnotic::Dummy::Server.new(port: port) }
  let(:connection) do
    Apnotic::Connection.new(
      uri:       "https://localhost:#{port}",
      cert_path: apn_file_path
    )
  end
  let(:device_id) { "device-id" }

  before { server.listen }
  after do
    connection.close
    server.stop
  end

  it "triggers a timeout when no response is received" do
    notification       = Apnotic::Notification.new(device_id)
    notification.alert = "test-notification"

    server.on_req = Proc.new { |_req| sleep 2 }

    response = connection.push(notification, timeout: 1)

    expect(response).to be_nil
  end

  it "triggers multiple timeouts when no responses are received" do
    notification_1       = Apnotic::Notification.new(device_id)
    notification_1.alert = "test-notification-1"
    notification_2       = Apnotic::Notification.new(device_id)
    notification_2.alert = "test-notification-2"

    server.on_req = Proc.new { |_req| sleep 2 }

    responses = []
    responses << connection.push(notification_1, timeout: 1)
    responses << connection.push(notification_2, timeout: 1)

    expect(responses.compact).to be_empty
  end
end