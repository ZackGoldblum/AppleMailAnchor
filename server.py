from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import subprocess

class MailRedirectHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        params = parse_qs(parsed.query)
        
        if 'id' in params:
            msg_id = params['id'][0]
            mail_url = f"message://%3C{msg_id}%3E"
            subprocess.run(['open', mail_url])
            
            html = b"""
            <html><body>
            <script>
                window.onload = function() {
                    setTimeout(function() { window.close(); }, 500);
                }
            </script>
            Opening in Mail...
            </body></html>
            """
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(html)
        else:
            self.send_response(400)
            self.end_headers()

    def log_message(self, format, *args):
        pass

print("Apple Mail Anchor server is running.")
HTTPServer(('localhost', 9876), MailRedirectHandler).serve_forever()
