from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, unquote
import subprocess

class MailRedirectHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        msg_id = None
        for part in parsed.query.split('&'):
            if part.startswith('id='):
                # unquote (not parse_qs) to preserve + signs in Gmail message IDs
                msg_id = unquote(part[3:])
                break

        if msg_id:
            msg_id = msg_id.strip('<>').strip()
            mail_url = f"message://%3C{msg_id}%3E"
            # osascript avoids `open` re-encoding % signs in the URL
            subprocess.run(['osascript', '-e', f'open location "{mail_url}"'])
            
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
