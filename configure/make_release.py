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


def read_release(filename):
    out = dict()
    with open(filename, 'r') as infile:
        for line in infile:
            # remove leading whitespace
            line = line.strip()
            if len(line) < 1:
                continue
            if line[0] == '#':
                continue

            token = line.split('=')
            if len(token) == 2:
                # we have a valid line
                out[token[0].strip()] = token[1].strip()
    return out


def modify_release(filename, release_dict):
    # read file into list
    infile = list()
    print("Reading RELEASE file {} ....".format(filename))
    with open(filename, 'r') as inf:
        for line in inf:
            infile.append(line)

    with write_out_file(filename, 'w', infile) as ouf:
        for line in infile:
            mline = line.strip()
            if len(mline) < 1:
                ouf.write(line)
                continue
            if mline[0] == '#':
                ouf.write(line)
                continue

            token = mline.split('=')
            if len(token) != 2:
                ouf.write(line)
                continue

            # Valid Line
            tok = token[0].strip()
            if tok.strip() in release_dict:
                print('---- Subst {}'.format(tok))
                out_line = '{}={}\n'.format(tok, release_dict[tok])
                ouf.write(out_line)
            else:
                ouf.write(line)


if __name__ == "__main__":
    files = sys.argv
    infile = sys.argv[1]
    modfiles = sys.argv[2:]
    rvars = read_release(infile)
    for filename in modfiles:
        print("Modifying file {} ....".format(filename))
        modify_release(filename, rvars)
