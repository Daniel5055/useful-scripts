Useful Scripts
==============

Here is a collection of useful shell scripts I have written when working with linux on the bash command line. These scripts were written for my WSL environment (single user Ubuntu) as quality of life improvements.

Agent Finder
============

This is a script which searches for any active ssh-agents.

Motivation
----------

As a university student I often use ssh to connect to the school servers. For security reasons, I need to enter a passphrase for my private key when connecting through ssh which often gets tedious when connecting multiple times in an hour. Therefore, I often utilise an ssh-agent to avoid continually entering my passphrase. However, when using wsl, I will often close and reopen sessions, create new sessions and so on, yet everytime I would need to add a new agent. Therefore, I created a script which searches for active ssh-agents through searching the user processes and returns the agent process id and the authentication socket.

Todo
====

Todo is essentially a todo list script with vairous features such as add, deleting and editing items added to it. It is also has some pretty ascii text retrieved from https://patorjk.com/software/taag. 

Motivation
----------

When working with linux and bash in general, I found I had many ideas and things to do and so I thought it would be a good idea to create a todo list program to manage these things. Due to the size of this program, this git repository was initially just for this todo list.

Additional Scripts
==================

I additionally have scripts that automate directory backing up and mailing however they have yet to be added due to containing personal information, and generally being too dependent on my own environment.



