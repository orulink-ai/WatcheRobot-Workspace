from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
import os, sys, time
root = r'D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_esp32\firmware\s3\build\app_center_ota_server'
log_path = r'D:\GithubRep\WatcheRobot-Workspace\ota_http_8767_access.log'
os.chdir(root)
class Handler(SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        line = '%s %s - %s\n' % (time.strftime('%Y-%m-%d %H:%M:%S'), self.client_address[0], fmt % args)
        with open(log_path, 'a', encoding='utf-8') as f:
            f.write(line)
        sys.stderr.write(line)
server = ThreadingHTTPServer(('0.0.0.0', 8767), Handler)
server.serve_forever()
