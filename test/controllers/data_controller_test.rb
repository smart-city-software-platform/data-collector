require 'test_helper'

class DataControllerTest < ActionDispatch::IntegrationTest
  setup do
    @datum = data(:one)
  end

  test "should get index" do
    get data_url
    assert_response :success
  end

  test "should get new" do
    get new_datum_url
    assert_response :success
  end

  test "should create datum" do
    assert_difference('Datum.count') do
      post data_url, params: { datum: { attribute: @datum.attribute, capability: @datum.capability, component_uuid: @datum.component_uuid, lat: @datum.lat, lon: @datum.lon, type: @datum.type, unity: @datum.unity, value: @datum.value } }
    end

    assert_redirected_to datum_path(Datum.last)
  end

  test "should show datum" do
    get datum_url(@datum)
    assert_response :success
  end

  test "should get edit" do
    get edit_datum_url(@datum)
    assert_response :success
  end

  test "should update datum" do
    patch datum_url(@datum), params: { datum: { attribute: @datum.attribute, capability: @datum.capability, component_uuid: @datum.component_uuid, lat: @datum.lat, lon: @datum.lon, type: @datum.type, unity: @datum.unity, value: @datum.value } }
    assert_redirected_to datum_path(@datum)
  end

  test "should destroy datum" do
    assert_difference('Datum.count', -1) do
      delete datum_url(@datum)
    end

    assert_redirected_to data_path
  end
end
