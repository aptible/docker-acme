#!/usr/bin/env python
import os
import json
import pem
from OpenSSL import crypto, SSL


def main():
    payload = os.environ["ACME_PAYLOAD"]
    domain = os.environ["ACME_DOMAIN"]
    h = json.loads(payload)

    chain = pem.parse(h["fullchain"])
    assert len(chain) > 1, "Chain has invalid length: {0}".format(len(chain))

    cert = crypto.load_certificate(crypto.FILETYPE_PEM, chain[0].as_bytes())
    cn = cert.get_subject().CN
    assert cn == domain, "Cert has invalid CN: {0}".format(cn)

    key = crypto.load_privatekey(crypto.FILETYPE_PEM, h["key"])

    # Verify key:
    # http://docs.ganeti.org/ganeti/2.14/html/design-x509-ca.html
    ctx = SSL.Context(SSL.TLSv1_METHOD)
    ctx.use_certificate(cert)
    ctx.use_privatekey(key)
    ctx.check_privatekey()

if __name__ == '__main__':
    main()
