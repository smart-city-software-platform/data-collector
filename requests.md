# Requests

Requests to this service usually involve receiving or sending a data structure
in JSON format. Check out the example below:


```json
{
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "Temperature": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
        "Humidity": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z"    
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "Quality": [
          {
            "value": "25.6",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    }
  ]
}
```


The fields presented on the above example may vary according to the request.


 Data Collector API 
====================

All interactions with the Data Collector are done through REST requests. Field description:  
  

* **uuid**: A non-quoted String corresponding to the resource's uuid 
(not to be confused with the local id assigned by the Data Collector!).
May have been upplied beforehand by the Discovery, or stored directly by the
client's application.
* **capabilities**: Capabilities are capacity that resources are able to
respond to which we keep the data.
* **value**:  The collected value. It can be an number (float,integer) or
string.
* **date**: This field respresent the date when the data was collected.

###  Getting data from all resources

`POST /resources/data`

**Description**:

Returns all the data history from all resources. Every data has an array of
Details; each Detail contains the value collected, the capability (such as
"temperature", "luminosity", ...) and date.

**Usage example**:

```shell
curl -X POST http://localhost:3000/resources/data`
```

Returns a JSON data structure similar to the following:

```json
 {
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "Temperature": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",
            
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
        "Humidity": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",
            
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "Quality": [
          {
            "value": "25.6",
            "date": "2016-06-21T23:27:35.000Z"
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned**:

*    **200 (OK)**: Request successful.
*    **500 (Internal Server Error)**: A problem in the Data Collector server occurred.


### Getting data from a specific resource or set of resources

`POST /resources/:uuid/data`

**Description**:

Returns all data history of an specified resources.

**Usage example for a specific resource**:

```shell
curl -X POST http://localhost:3000/resources/102503b2-59ee-445c-a20b-99fd10b01c19/data
```

**Usage example for a set of resources**:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value":{"uuids":["5ad20589-a3db-4521-b1bc-a21dde00a25c","b5d170b5-aaf3-42bc-9e47-58e3fe2a4846"]}}' http://localhost:3000/resources/data
```

Returns a JSON data structure similar to the following:

```json
{
"resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "Temperature": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",
            
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
        "Humidity": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",
            
          },
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned**:

*    **200 (OK)**: Request successful.
*    **400 (Bad Request)**: Returned when the specified :uuid was not found.
*    **500 (Internal Server Error)**: A problem in the Data Collector server occurred.

### Getting last data from a specific resource or set of resources 

`POST /resources/:uuid/data/last`

**Description**:

Returns the last Data collected from the capability of a specific resource.

**Usage example for a specific resource**:

```shell
curl -X POST http://localhost:3000/resources/102503b2-59ee-445c-a20b-99fd10b01c19/data/last
```

**Usage example for a set of resources**:

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value":{"uuid":["5ad20589-a3db-4521-b1bc-a21dde00a25c","b5d170b5-aaf3-42bc-9e47-58e3fe2a4846"]}}' http://localhost:3000/resources/data/last
```

Returns a JSON data structure similar to the following:

```json
{
"resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "Temperature": [
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ],
        "Humidity": [
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned:**

*   **200 (OK):** Request successful.
*    **400 (Bad Request):** Returned when the specified :uuid was not found.
*    **500 (Internal Server Error):** A problem in the Data Collector server occurred.

### Getting the last data from all resources

`POST /resources/data/last`

**Description:**

Returns the last Data collected from the capability of a all resources. 

**Usage example:**

```shell
curl -X POST http://localhost:3000/resources/data/last
```

Returns a JSON data structure similar to the following:

```json
{
  "resources": [
    {
      "uuid": "ae9cf502-5ed2-47d4-914c-c1caec1c41c4",
      "capabilities": {
        "Temperature": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",          
          }
        ],
        "Humidity": [
          {
            "value": "38.313",
            "date": "2016-06-21T23:27:35.000Z",
          }
        ]
      }
    },
    {
      "uuid": "56tcf598-3tg1-77d9-034t-w5ajis5u44c7",
      "capabilities": {
        "Quality": [
          {
            "value": "28.237",
            "date": "2016-06-20T06:37:52.000Z"
          }
        ]
      }
    }
  ]
}
```

**HTTP status codes returned:**

   * **200 (OK):** Request successful.
   * **500 (Internal Server Error):** A problem in the Data Collector server occurred.


Filters
============================

**Field Description**

* **capabilities:**  Represent the values of capabilities, for example, temperature, luminosity and etc.Can be a string or array.
* **start_range/end_range:** Represent the date value in ISO- 8601 format.It's a DateTime.
* **equal/min/max:** Represent the sensor values.It's a float.


### By capability

**Description:**

Filter the data collected by capability or a capability range.

**Usage example for a capability**

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value":{"capabilities":"tofu"}}' http://localhost:3000/resources/data
```
Usage example for a range capability

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value":{"capabilities":["tofu","loko","flannel","meditation"]}}' http://localhost:3000/resources/data
```

### By date

Filter the data collected by date.This filter can be applied using a date or a range date.

Usage example for date

```shell
curl -H "Content-Type: application/json" -X POST -d '{"start_range":"2016-06-25T12:21:29"}' http://localhost:3000/resources/data
```

Usage  example for range date

```shell
curl -H "Content-Type: application/json" -X POST -d '{"start_range":"2016-06-25T12:21:29","end_range":"2016-06-25T16:21:29"}' http://localhost:3000/resources/data
```

### By Value

Filter the data collected by value.This filter can be applied using a max, min, equal value or a range value.

**Usage example for a value**

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value": {"range":{"chillwave":{"equal":"13.498"} } } }' http://localhost:3000/resources/data
```

Usage example for a range value

```shell
curl -H "Content-Type: application/json" -X POST -d '{"sensor_value": {"range":{"chillwave":{"min":"13.498","max":"18.091"} }}}' http://localhost:3000/resources/data
```

**HTTP status codes returned:**

*  **200 (OK):** Request successful.
*  **400 (Bad Request):** Returned when the specified parameter was not found.
*  **500 (Internal Server Error):** A problem in the Data Collector server occurred.

