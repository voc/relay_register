# relay register

## Usage

### Register new relay

Sending data to `/register` to register a new relay can be done with curl

```
curl -k -H "CONTENT-TYPE: application/json" -d "{"iv":"1231234345354", "data":{…}}"
```

or use the ruby client in examples folder.

The API expects the following object resources in JSON format:

```
{
  "iv": "iv",
  "data": {
    "api_key": "api_key",
    "raw_data": {
      "hostname": "#{`hostname -f`}",
      "lspci": "#{`lspci`}",
      "ip_config": "#{`ip a`}",
      "disk_size": "#{`df -h`}",
      "memory": "`#{free -m`}",
      "cpu": "#{File.read('/proc/cpuinfo')}"
    }
  }
}
```

`data` needs to be `AES-256-CBC` encrypted and Base64 encoded.

## Create archive

    ```
     wget --http-user=winke --http-password=katze --mirror --page-requisites \
          --adjust-extension --convert-links https://c3voc.de/31c3/register
    ```

## Install

1. Clone repository.

2. Install dependencies.

    ```
     bundle install
    ```

3. Create `settings.yml`

    ```
      cp settings.yml.example settings.yml
    ```

    ```
      vim settings.yml
    ```

4. Test installation and run application with puma.

    ```
     ruby webapp.rb
    ```

## Deployment

It is highly recommended to deploy this application with passenger or comparable webservers.

## License

Copyright (c) 2014-2015, c3voc<br>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
