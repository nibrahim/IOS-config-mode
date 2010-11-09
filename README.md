Cisco IOS config mode
=====================

ios-config-mode is an Emacs major mode that helps to view and edit
Cisco IOS (tm) configuration files.

Features include:

   * Font locking rules. 
   * Imenu support
   * Indentation
   * Convenience routines to add lines to interface blocks (eg. shut all
   interfaces).


The mode consists of two files 

  1. The mail mode itself (with the syntax rules and other usual
     features) - `ios-config-mode.el`.
  2. An addon file which contains some routines that provide easy
     interfaces for common tasks (like shutdown all interfaces) -
     `ios-config-addons.el`. This file also contains two simple
     functions that can be used as templates to write more complex ones
     which modify the buffer contents.

For comments, suggestions and fixes, please contact Noufal Ibrahim
noufal@nibrahim.net.in

