the following is an azure cli script provided by azure copilot to help me generate a dashboard for cpu and network performance for a specific rg.

Create a JSON file for the dashboard definition:

{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": {
            "x": 0,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "resourceType",
                "value": "Microsoft.Compute/virtualMachines"
              },
              {
                "name": "resourceGroup",
                "value": "CGI-Enterprise"
              }
            ],
            "type": "Extension/Microsoft_Azure_Monitoring/TimeSeries"
          }
        },
        "1": {
          "position": {
            "x": 3,
            "y": 0,
            "colSpan": 3,
            "rowSpan": 3
          },
          "metadata": {
            "inputs": [
              {
                "name": "resourceType",
                "value": "Microsoft.Compute/virtualMachines"
              },
              {
                "name": "resourceGroup",
                "value": "CGI-Enterprise"
              }
            ],
            "type": "Extension/Microsoft_Azure_Monitoring/TimeSeries"
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": {
          "relative": {
            "duration": 24,
            "timeUnit": 1
          }
        },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      }
    }
  }
}

Use the following Azure CLI command to create the dashboard:

az portal dashboard create --input-path dashboard.json --name level2salomon --resource-group CGI-Enterprise

than say yes to portal download.

Getting an error.....