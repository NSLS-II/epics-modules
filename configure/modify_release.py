#!/usr/bin/env python
from __future__ import print_function
import sys


class write_out_file(object):
    def __init__(self, file_name, method, contents):
        self.file_name = file_name
        self.contents = contents
        self.file_obj = open(file_name, method)

    def __enter__(self):
        return self.file_obj

    def __exit__(self, type, value, traceback):
        self.file_obj.close()
        if type is not None:
            with open(self.file_name, 'w') as f:
                for line in self.contents:
                    f.write(line)
            return False

        return True


def modify_release(filename, token, unset=True, val=None):
    # read file into list
    infile = list()
    print("Reading RELEASE file {} ....".format(filename))
    with open(filename, 'r') as inf:
        for line in inf:
            infile.append(line)

    with write_out_file(filename, 'w', infile) as ouf:
        for line in infile:
            mline = line.strip()
            if len(mline) < 3:
                ouf.write(line)
                continue

            tokens = mline.split('=')
            if len(tokens) != 2:
                ouf.write(line)
                continue

            tok = tokens[0].strip()
            tok = tok.replace('#', '')
            if tok == token:
                if val is None:
                    if unset:
                        print('---- Unsetting {}'.format(tok))
                        ouf.write('#{}'.format(line))
                    else:
                        print('---- Setting {}'.format(tok))
                        ouf.write('{}={}\n'.format(tok, tokens[1]))
                else:
                    print('---- Modifying {} to {}'.format(tok, val))
                    ouf.write('{}={}\n'.format(tok, val))
            else:
                ouf.write(line)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(127)
    filename = sys.argv[1]
    token = sys.argv[2]
    val = sys.argv[3]
    unset = False

    if val == 'UNSET':
        val = None
        unset = True
    elif val == 'SET':
        val = None
        unset = False

    modify_release(filename, token, unset, val)
