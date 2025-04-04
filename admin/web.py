# -*- coding: utf-8 -*-
import os
import sys
import time
import argparse
import threading
import subprocess
from http.server import SimpleHTTPRequestHandler
from ..core.conf import Conf
from ..web.webserver import WebServer, HttpHandler, HttpHandler_Redirect
from ..core import fn
from ..core import crypt
from ..db.dsn import Dsn


class Main:
    def __init__(self, args: argparse.Namespace = None):
        c = Conf('web.json')
        # Iniciar servidores com parâmetros
        WebServer.HTTP_PORT = 80
        WebServer.HTTPS_PORT = 443
        WebServer.KEYFILE = "/cer/key.pem"
        WebServer.CERTFILE = "/cer/cert.pem"

        threading.Thread(
            target=WebServer,
            kwargs={"https": True, "handler": HttpHandler},  # HTTPS
            daemon=True
        ).start()
        threading.Thread(
            target=WebServer,
            kwargs={"https": False, "handler": HttpHandler_Redirect},  # HTTP
            daemon=True
        ).start()

    # HTTPS
    # linux: openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes


if __name__ == "__main__":
    print('This lib must be called by root of your project started by this framework by another script')
    quit()
