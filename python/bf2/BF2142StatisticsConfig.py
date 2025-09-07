# ------------------------------------------------------------------------------
# omero 2006-02-27
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# START CONFIGURATION
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Debug Logging
# ------------------------------------------------------------------------------
debug_enable = 0
debug_log_path = 'python/bf2/logs'		# Relative from BF2 base folder
debug_fraglog_enable = 0				# Detailed 'Fragalyzer' Logs

# ------------------------------------------------------------------------------
# backend (webserver) listening on TCP/IP address and port
# ------------------------------------------------------------------------------
http_backend_addr = 'stella.prod.emawind.com'
http_backend_port = 80

# ------------------------------------------------------------------------------
# RELATIVE path (webserver document root directory) to main backend script
# ------------------------------------------------------------------------------
http_backend_asp = '/bf2142statistics.php'

# ------------------------------------------------------------------------------
# Snapshot Logging
# ------------------------------------------------------------------------------
# Enables server to make snapshot backups.
# 0 = log only on error sending to backend
# 1 = all snapshots
# ------------------------------------------------------------------------------
snapshot_logging = 0
snapshot_log_path_sent = 'python/bf2/logs/snapshots/sent' 		# Relative from the BF2 base folder
snapshot_log_path_unsent = 'python/bf2/logs/snapshots/unsent' 	# Relative from the BF2 base folder

# ------------------------------------------------------------------------------
# PREFIX the log/snapshot with an arbitrary string
# ------------------------------------------------------------------------------
snapshot_prefix = 'BF2142'

# ------------------------------------------------------------------------------
# All AI Players (Bots) will be assigned the following address (country pourpose)
# ------------------------------------------------------------------------------
aiplayer_addr='127.0.0.1'

# ------------------------------------------------------------------------------
# END CONFIGURATION
# ------------------------------------------------------------------------------
