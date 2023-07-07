import 'dart:convert';

/// This is a Firestore update record in protobuf
final protobytes = base64Decode(
  'CoIBClFwcm9qZWN0cy9kYXJ0LXJlZGlyZWN0b3IvZGF0YWJhc2VzLyhkZWZhdWx0KS9kb2N1bWVu'
  'dHMvdXNlcnMvZ2hYTnRlUElGbWRET0JIM2lFTUgSEQoEbmFtZRIJigEGbHVjaWE0GgwI6+KupAYQ'
  'iMa2qgIiDAjF1sukBhCY2qvFARKCAQpRcHJvamVjdHMvZGFydC1yZWRpcmVjdG9yL2RhdGFiYXNl'
  'cy8oZGVmYXVsdCkvZG9jdW1lbnRzL3VzZXJzL2doWE50ZVBJRm1kRE9CSDNpRU1IEhEKBG5hbWUS'
  'CYoBBmx1Y2lhMxoMCOvirqQGEIjGtqoCIgwI8o60pAYQmJa6igMaBgoEbmFtZQ==',
);

const jsonOutput = {
  'value': {
    'name':
        'projects/dart-redirector/databases/(default)/documents/users/ghXNtePIFmdDOBH3iEMH',
    'fields': {
      'name': {'stringValue': 'lucia4'},
    },
    'createTime': '2023-06-16T00:48:43.625845Z',
    'updateTime': '2023-06-21T12:21:25.413855Z',
  },
  'oldValue': {
    'name':
        'projects/dart-redirector/databases/(default)/documents/users/ghXNtePIFmdDOBH3iEMH',
    'fields': {
      'name': {'stringValue': 'lucia3'},
    },
    'createTime': '2023-06-16T00:48:43.625845Z',
    'updateTime': '2023-06-17T01:08:02.827231Z',
  },
  'updateMask': {
    'fieldPaths': ['name'],
  },
};
