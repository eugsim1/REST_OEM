########
## from Linux
#######

##### to run the below scripts you need an OEM with a minimum RU14
#####
#####
#### replace the XXXXXXXXXXXXXXX with your own settings
cd /home/oracle/eomRESTAPI

cat<<EOL>generate_REST_API_OEM_config.sh

echo -n "${OEM_user}:${OEM_user_password}" | base64>basic-auth.txt


cat basic-auth.txt


cat<<-EOT>defaults_oem.yaml
##### global vars
basic_auth: "basic-auth.txt"
oem_url   : "${OEM_URL}"
EOT

cat defaults_oem.yaml

cat<<EOF>01-get-Named-credentials.yaml
---
- name : Using a REST API
  connection: local
  hosts: localhost
  vars_files:
   - defaults_oem.yaml
  tasks:

    - name: Get Named Credentials
      uri:
       url: "{{ oem_url }}/api/namedCredentials"
       method: GET
       return_content: yes
       force_basic_auth: yes
       validate_certs: no
       headers:
         Authorization: Basic "{{ basic_auth }}"
         Content-Type: application/json
      register: result
      ignore_errors: yes


    - name: Dump Credentials
      debug:
        msg: '{{result | json_query(jsmquery)}}'
      vars: 
        jsmquery: "json.items"
      register: result_json
      tags:
        - test-oem-Credentials

    - name: write_2_file
      copy:
        dest: "/home/oracle/eomRESTAPI/namedCredentials.csv"    
        content: |
          {%for h in result_json.msg %}
          {{h}}
          {% endfor %}

    - name: write_2_file_users
      copy:
        dest: "/home/oracle/eomRESTAPI/users_namedcred.csv"    
        content: |
          {%for h in result_json.msg %}
          {{h.name}}|{{h.owner}}|{{h.scope}}|{{h.targetTypeName}}|{{h.targetUsername}}|{{h.type}}
          {% endfor %}

  


EOF

cat 01-get-Named-credentials.yaml



cat<<EOF>01-Test-Named-credentials.yaml
---
- name : Using a REST API
  connection: local
  hosts: localhost
  vars_files:
   - defaults_oem.yaml
  tasks:

    - name: Test Named Credentials
      ansible.builtin.uri:
       url: "{{ oem_url }}/api/namedCredentials/XXXXXXXXXXXXXXXXXXXXXXXXX/actions/test"
       method: POST
       return_content: yes
       force_basic_auth: yes
       validate_certs: no
       body_format: json
       status_code: 204
       headers:
         Authorization: Basic "{{ basic_auth }}"
       body:
              {
                "authenticationTestTargetName":"XXXXXXXX",
                "authenticationTestTargetTypeName":"host"
              }
      register: result
      ignore_errors: yes

    - name: debug server test
      debug: 
        msg: Test succesfull 
      when: result.status == 204
EOF

cat<<EOF>01-Create-Named-credentials.yaml
---
- name : Using a REST API
  connection: local
  hosts: localhost
  vars_files:
   - defaults_oem.yaml
  tasks:

    - name: Test Named Credentials
      ansible.builtin.uri:
       url: "{{ oem_url }}/api/namedCredentials"
       method: POST
       return_content: yes
       force_basic_auth: yes
       validate_certs: no
       body_format: json
       status_code: 201
       headers:
         Authorization: Basic "{{ basic_auth }}"
       body:
          {
              "name": "PDB_ADMIN_SYS2",
              "description": "Named credential for database",
              "owner": "SYSMAN",
              "authenticatingTargetTypeName": "oracle_database",
              "type": "DBCreds",
              "scope": "GLOBAL",
              "attributes": {
                  "DBUserName": "SYS",
                  "DBPassword": "XXXXXXXXXXX",
                  "DBRole": "SYSDBA"
              }

          }
      register: result
      ignore_errors: yes

    - name: debug server test
      debug: 
        msg: Test succesfull 
      when: result.status == 201
EOF


cat<<EOF>01-Delete-Named-credentials.yaml
---
- name : Using a REST API
  connection: local
  hosts: localhost
  vars_files:
   - defaults_oem.yaml
  tasks:

    - name: Delete-Named-credentials
      ansible.builtin.uri:
       url: "{{ oem_url }}/api/namedCredentials/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
       method: DELETE
       return_content: yes
       force_basic_auth: yes
       validate_certs: no
       body_format: json
       status_code: 204
       headers:
         Authorization: Basic "{{ basic_auth }}"
      register: result
      ignore_errors: yes

    - name: debug server test
      debug: 
        msg: Test succesfull 
      when: result.status == 204
EOF

cat<<EOF>01-List_Targets.yaml
---
- name : Using a REST API
  connection: local
  hosts: localhost
  vars_files:
   - defaults_oem.yaml
  tasks:

    - name: List Teragts
      ansible.builtin.uri:
       url: "{{ oem_url }}/api/targets"
       method: GET
       return_content: yes
       force_basic_auth: yes
       validate_certs: no
       body_format: json
       status_code: 204
       headers:
         Authorization: Basic "{{ basic_auth }}"

      register: result
      ignore_errors: yes

    - name: debug server test
      debug: 
        msg: Test succesfull 
      when: result.status == 204
EOF


EOL

cat generate_REST_API_OEM_config.sh
#### uncomment the below lines to test the REST api with your OEM 13.5 RU 14 +
#### modification from linux
### ansible-playbook  01-List_Targets.yaml
	  

###ansible-playbook 	 01-get-Named-credentials.yaml
###cat nmsg.csv |  jq  .json.items

EOL

cat generate_REST_API_OEM_config.sh
