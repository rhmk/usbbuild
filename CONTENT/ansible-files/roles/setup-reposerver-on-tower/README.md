setup-reposerver
================

A brief description of the role goes here.

Requirements
------------

The server should have been registered against Red Hat Network and must have enough diskspace at /var/www/html. You can use

 - mk-ansible-roles.subscribe-rhn
 - mk-ansible-roles.disk-init

to configure your systems accordingly

Role Variables
--------------

If you want to serve the packages on special IP address you can specify *reposync_server*. It defaults to *ansible_hostname* if not set otherwise

The reposync parameters default to *-n -d -l --downloadcomps --download-metadata*, which download the group definitions and only keep the latest version of a package. Use *reposync_param* if you want to change these parameters.

As a default the cron script is copied to /usr/sbin. If reposync_cron is set to monthly or daily an appropriate link is set

    reposync_server: "{{ ansible_hostname }}"
    reposync_param: -n -d -l --downloadcomps --download-metadata
    reposync_cron: [false|daily|monthly]

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: reposerver
      roles:
         - { role: mk-ansible-roles.setup-reposerver }

License
-------

Apache License
Version 2.0, January 2004

Author Information
------------------

Markus Koch

Please leave comments in the github repo issue list
