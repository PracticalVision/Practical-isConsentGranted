___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Practical isConsentGranted",
  "categories": ["ANALYTICS", "TAG_MANAGEMENT", "UTILITY"],
  "description": "Quickly verify consent states (\"granted\"/\"denied\") for GTM consent types, individually or multiple at once. Ideal for privacy-focused tracking. Made with care and ❤️ by Practical Vision.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "LABEL",
    "name": "intro_text",
    "displayName": "This variable can verify either a single consent type or multiple consent types simultaneously"
  },
  {
    "type": "LABEL",
    "name": "...",
    "displayName": ".   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   ."
  },
  {
    "type": "CHECKBOX",
    "name": "multiple_consent_checkup",
    "checkboxText": "Check multiple consent types",
    "simpleValueType": true,
    "help": "Tick to check more than one consent type. When selected use the table below to add one rule per consent type.",
    "alwaysInSummary": true
  },
  {
    "type": "SELECT",
    "name": "consent_type",
    "displayName": "Consent Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "ad_storage",
        "displayValue": "ad_storage"
      },
      {
        "value": "ad_user_data",
        "displayValue": "ad_user_data"
      },
      {
        "value": "ad_personalization",
        "displayValue": "ad_personalization"
      },
      {
        "value": "analytics_storage",
        "displayValue": "analytics_storage"
      },
      {
        "value": "functionality_storage",
        "displayValue": "functionality_storage"
      },
      {
        "value": "personalization_storage",
        "displayValue": "personalization_storage"
      },
      {
        "value": "security_storage",
        "displayValue": "security_storage"
      }
    ],
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Select the consent type you want to check. The variable returns \"granted\" or \"denied\" based on the current consent state or \"not set\" if the event is gtm.init_consent. This option is disabled when \"Check multiple consent types\" is ticked.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "multiple_consent_checkup",
        "paramValue": false,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "multiple_consent_types",
    "displayName": "Select the desired consent condition",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Consent Type",
        "name": "consent_type",
        "type": "SELECT",
        "selectItems": [
          {
            "value": "ad_storage",
            "displayValue": "ad_storage"
          },
          {
            "value": "ad_user_data",
            "displayValue": "ad_user_data"
          },
          {
            "value": "ad_personalization",
            "displayValue": "ad_personalization"
          },
          {
            "value": "analytics_storage",
            "displayValue": "analytics_storage"
          },
          {
            "value": "functionality_storage",
            "displayValue": "functionality_storage"
          },
          {
            "value": "personalization_storage",
            "displayValue": "personalization_storage"
          },
          {
            "value": "security_storage",
            "displayValue": "security_storage"
          }
        ]
      },
      {
        "defaultValue": "",
        "displayName": "Desired state",
        "name": "desired_state",
        "type": "SELECT",
        "selectItems": [
          {
            "value": "granted",
            "displayValue": "granted"
          },
          {
            "value": "denied",
            "displayValue": "denied"
          }
        ]
      }
    ],
    "help": "Add a row for each consent rule you want to check. Each row must define a consent type and its desired state. The variable returns true only when all rows match the current consent state and false if any row fails. If the event is gtm.init_consent, the variable returns \"not set\".Add a row for each consent rule you want to check. Each row must define a consent type and its desired state. The variable returns true only when all rows match the current consent state and false if any row fails. If the event is gtm.init_consent, the variable returns \"not set\".",
    "enablingConditions": [
      {
        "paramName": "multiple_consent_checkup",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "newRowButtonText": "Add consent check",
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "LABEL",
    "name": "credit",
    "displayName": "Made with care and ❤️ by Practical Vision ✔️"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const isConsentGranted = require('isConsentGranted');
const copyFromDataLayer = require('copyFromDataLayer');
const logToConsole = require('logToConsole');
const JSON = require('JSON');

const eventName = copyFromDataLayer('event');
logToConsole('data:', JSON.stringify(data));
logToConsole('eventName:', eventName);

if (eventName === 'gtm.init_consent') {
  logToConsole('skipping consent check on init_consent');
  return 'not set';
}

/* -------------------------------------------------
   MULTIPLE CONSENT CHECK (checkbox enabled)
   ------------------------------------------------- */
if (data.multiple_consent_checkup) {
  const rows = data.multiple_consent_types || [];
  if (!rows.length) {
    logToConsole('no rows configured in multiple_consent_types');
    return 'false';
  }

  for (let i = 0; i < rows.length; i++) {
    const row        = rows[i];
    const cType      = row.consent_type;
    const desired    = row.desired_state;
    const isGranted  = isConsentGranted(cType);

    logToConsole(
      'row', i,
      'consent_type:', cType,
      'desired_state:', desired,
      'isGranted:', isGranted
    );

    /* If any row fails its condition, whole check fails */
    if (
      (desired === 'granted' && !isGranted) ||
      (desired === 'denied'   &&  isGranted)
    ) {
      logToConsole('row failed, returning false');
      return false;
    }
  }

  logToConsole('all rows passed, returning true');
  return true;
}

/* -------------------------------------------------
   SINGLE CONSENT CHECK (default branch)
   ------------------------------------------------- */
const cType     = data.consent_type;
const isGranted = isConsentGranted(cType);
logToConsole('single consent check for', cType, '=>', isGranted);

return isGranted ? 'granted' : 'denied';


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_personalization"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "functionality_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "personalization_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "security_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Skip init_consent
  code: |-
    // Override event name
    mock('copyFromDataLayer', () => 'gtm.init_consent');

    const mockData = {};

    let result = runCode(mockData);
    assertThat(result).isEqualTo('not set');
- name: Single consent granted (analytics_storage)
  code: |-
    // Default map already grants analytics_storage
    const mockData = { consent_type: 'analytics_storage' };

    let result = runCode(mockData);
    assertThat(result).isEqualTo('granted');
- name: Multiple consent – all rows pass
  code: |-
    // analytics_storage is granted, ad_storage is denied → desired states match
    const mockData = {
      multiple_consent_checkup: true,
      multiple_consent_types: [
        { consent_type: 'analytics_storage', desired_state: 'granted' },
        { consent_type: 'ad_storage',        desired_state: 'denied' }
      ]
    };

    let result = runCode(mockData);
    assertThat(result).isEqualTo(true);
- name: Multiple consent – fails when ad_storage expected granted
  code: |-
    // ad_storage is denied by default but desired_state is 'granted' → should fail
    const mockData = {
      multiple_consent_checkup: true,
      multiple_consent_types: [
        { consent_type: 'ad_storage', desired_state: 'granted' }
      ]
    };

    let result = runCode(mockData);
    assertThat(result).isEqualTo(false);
setup: |-
  const consentState = {
    ad_storage:            false,
    ad_user_data:          false,
    ad_personalization:    false,
    analytics_storage:     true,
    functionality_storage: true,
    personalization_storage: true,
    security_storage:      true
  };

  // Mock isConsentGranted – granted unless explicitly false
  mock('isConsentGranted', type => consentState[type] !== false);

  // Default event
  mock('copyFromDataLayer', () => 'gtm.js');


___NOTES___

Created on 5/31/2025, 8:35:53 PM