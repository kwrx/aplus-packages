#!/bin/env python3

import argparse
import os
import subprocess
import wget
import yaml
import shutil
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

environ = os.environ.copy()


parser = argparse.ArgumentParser(description='Build the project')
parser.add_argument('-i', '--install', help='Install the package', default='*', nargs='+')
parser.add_argument('-c', '--clean', help='Clean all packages', action='store_true')
parser.add_argument('--tmpdir', default='/tmp/aplus-packages-build', help='Temporary directory')
parser.add_argument('--host', default='x86_64-aplus', help='Host architecture')
parser.add_argument('--root', default='.', help='Root directory')
parser.add_argument('--verbose', action='store_true', help='Verbose output')
args = parser.parse_args()


def run_command(cmd, cwd=None):
    subprocess.run(cmd, shell=True, check=True, cwd=cwd)

def scan(path):

    for root, _, files in os.walk(path):

        for file in files:

            if not file.endswith('package.yml'):  
                continue  

            yield root


def format_package_env_name(name):
    return '$PACKAGE_{}'.format(name.upper().replace('-', '_').replace('.', '_').replace('+', '_').replace('@', '_'))

def resolve(packages, package, s):

    for p in packages:

        if format_package_env_name(p['package']) not in s:
            continue

        s = s.replace(format_package_env_name(p['package']), os.path.join(args.tmpdir, p['package'] + '-' + p['version']))


    s = s.replace('$HOST', args.host)
    s = s.replace('$ROOT', args.root)
    s = s.replace('$TMP',  args.tmpdir)
    s = s.replace('$SRCDIR', os.path.join(args.tmpdir, package['package'] + '-' + package['version']))
    s = s.replace('$BUILDDIR', os.path.join(args.tmpdir, package['package'] + '-' + package['version'], '__build'))
    s = s.replace('$SYSROOT', os.path.join(args.tmpdir, package['package'] + '-' + package['version'], '__out'))
    s = s.replace('$PKGDIR', package['root'])
    s = s.replace('$PACKAGE', package['package'])
    s = s.replace('$VERSION', package['version'])

    s = s.replace('\'', '\\\'')
    s = s.replace('"', '\\"')

    return s



def prepare(packages, package, env=True):

    srcdir = os.path.join(args.tmpdir, f'{package["package"]}-{package["version"]}')
    
    if not os.path.exists(os.path.join(srcdir, '__build')):
        os.mkdir(os.path.join(srcdir, '__build'))

    if not os.path.exists(os.path.join(srcdir, '__out')):
        os.mkdir(os.path.join(srcdir, '__out'))


    for k in os.environ:
        if k not in environ:
            os.unsetenv(k)

    if env and 'env' in package['build']:

        for env in package['build']['env']:

            for k, v in env.items():

                os.environ[k] = resolve(packages, package, v)
                os.putenv(k, os.environ[k])

                if args.verbose:
                    print(f'   + {k}={os.environ[k]}')

    return srcdir




def build(packages, package):

    if package['status'] == 'done':
        return

    if 'dependencies' in package:

        for dep in package['dependencies']:

            if args.verbose:
                print(f' - Dependency {dep}')

            found = False
            for p in packages:

                if p['package'] != dep:
                    continue
            
                if p['status'] == 'done':
                    found = True
                    break

                if p['status'] == 'building':
                    raise Exception(f'Circular dependency detected: {package} -> {dep}')

                build(packages, p)
                found = True
                break

            if not found:
                raise Exception(f'Dependency {dep} not found for package {package["package"]}')


    if not 'build' in package:
        package['status'] = 'done'
        return

    package['status'] = 'building'

    srcdir = prepare(packages, package)
    curdir = os.curdir

    if args.clean:
        shutil.rmtree(os.path.join(srcdir, '__build'))
        shutil.rmtree(os.path.join(srcdir, '__out'))
        os.mkdir(os.path.join(srcdir, '__build'))
        os.mkdir(os.path.join(srcdir, '__out'))


    run_command(f'env > {srcdir}/__build/env.log')

    if 'preconfigure' in package['build']:

        print(f' - Before configure {package["package"]}:{package["version"]}')

        for cmd in package['build']['preconfigure']:

            cmd = resolve(packages, package, cmd)

            if args.verbose:
                print(f'   + {cmd}')

            os.chdir(os.path.join(srcdir))
            run_command(f'{cmd} 1> __build/preconfigure.log 2> __build/preconfigure.err')
            os.chdir(curdir)


    if 'configure' in package['build']:

        print(f' - Configuring {package["package"]}:{package["version"]}')

        opts = package["build"]["configure"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')


        if os.path.exists(f'{srcdir}/configure'):

            os.chdir(os.path.join(srcdir, '__build'))
            run_command(f'{srcdir}/configure {" ".join(opts)} 1> configure.log 2> configure.err')
            os.chdir(curdir)

        elif os.path.exists(f'{srcdir}/meson.build'):

            os.chdir(srcdir)
            run_command(f'meson setup {" ".join(opts)} {srcdir}/__build 1> __build/configure.log 2> __build/configure.err')
            os.chdir(curdir)

        elif os.path.exists(f'{srcdir}/CMakeLists.txt'):

            os.chdir(srcdir)
            run_command(f'cmake -G "Unix Makefiles" -S {srcdir} -B {srcdir}/__build {" ".join(opts)} 1> __build/configure.log 2> __build/configure.err')
            os.chdir(curdir)

        else:

            raise Exception(f'No configure script found in {srcdir}')


    if 'premake' in package['build']:

        print(f' - Before build {package["package"]}:{package["version"]}')

        for cmd in package['build']['premake']:

            cmd = resolve(packages, package, cmd)

            if args.verbose:
                print(f'   + {cmd}')

            os.chdir(os.path.join(srcdir))
            run_command(f'{cmd} 1> __build/premake.log 2> __build/premake.err')
            os.chdir(curdir)


    if 'make' in package['build']:
    
        print(f' - Building {package["package"]}:{package["version"]}')

        opts = package["build"]["make"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')


        os.chdir(srcdir)


        if os.path.exists('__build/Makefile'):

            run_command(f'make -C __build {" ".join(opts)} 1> __build/make.log 2> __build/make.err')

        elif os.path.exists('Makefile'):

            run_command(f'make {" ".join(opts)} 1> __build/make.log 2> __build/make.err')

        elif os.path.exists('__build/build.ninja'):

            run_command(f'ninja -C {srcdir}/__build {" ".join(opts)} 1> __build/make.log 2> __build/make.err')

        else:

            raise Exception(f'No makefile found in {srcdir}')

        os.chdir(curdir)


    if 'postmake' in package['build']:

        print(f' - After build {package["package"]}:{package["version"]}')

        for cmd in package['build']['postmake']:

            cmd = resolve(packages, package, cmd)

            if args.verbose:
                print(f'   + {cmd}')

            os.chdir(os.path.join(srcdir))
            run_command(f'{cmd} 1> __build/postmake.log 2> __build/postmake.err')
            os.chdir(curdir)


    if 'install' in package['build']:

        print(f' - Installing {package["package"]}:{package["version"]}')

        opts = package["build"]["install"]
        opts = [resolve(packages, package, i) for i in opts]

        if args.verbose:
            print(f'   + {opts}')


        os.chdir(srcdir)


        if os.path.exists('__build/Makefile'):

            run_command(f'make -C __build install {" ".join(opts)} 1> __build/install.log 2> __build/install.err')
    
        elif os.path.exists('Makefile'):

            run_command(f'make install {" ".join(opts)} 1> __build/install.log 2> __build/install.err')

        elif os.path.exists('__build/build.ninja'):

            run_command(f'ninja -C {srcdir}/__build install {" ".join(opts)} 1> __build/install.log 2> __build/install.err')

        else:

            raise Exception(f'No makefile found in {srcdir}')

        os.chdir(curdir)


    if 'postinstall' in package['build']:

        print(f' - After install {package["package"]}:{package["version"]}')

        for cmd in package['build']['postinstall']:

            cmd = resolve(packages, package, cmd)

            if args.verbose:
                print(f'   + {cmd}')

            os.chdir(os.path.join(srcdir))
            run_command(f'{cmd} 1> __build/postinstall.log 2> __build/postinstall.err')
            os.chdir(curdir)



    package['status'] = 'done'


def resolve_package(packages, name):

    for package in packages:
        if package['package'] == name:
            return package

    raise Exception(f'Package {name} not found')


def resolve_candidates(packages, candidates, resolved=[]):
    
    for candidate in candidates:

        if candidate in resolved:
            continue

        resolved.append(candidate)

        if 'dependencies' in candidate:

            for dep in candidate['dependencies']:
                candidate = resolve_package(packages, dep)
                if candidate not in candidates:
                    candidates = resolve_candidates(packages, candidates + [candidate], resolved)

    return candidates


def stage_1(packages):

    print('Scanning for packages')

    for package in scan(args.root):

        with(open(os.path.join(package, 'package.yml'))) as fp:

            yml = yaml.safe_load(fp)

            if 'package' not in yml:
                continue

            if 'version' not in yml:
                continue

            if 'sources' not in yml:
                continue

            if args.verbose:
                print(f' - Found {yml["package"]}-{yml["version"]}')


            yml['root']   = package
            yml['status'] = 'init'

            packages.append(yml)


    if args.install != '*':

        candidates = [i for i in packages if i['package'] in args.install]
        candidates = resolve_candidates(packages, candidates)

        packages = candidates


    return packages



def stage_2(packages):

    print('Fetching sources')

    for package in packages:

        print(f' - GET {package["package"]}:{package["version"]}')

        package['archives'] = []

        for source in package['sources']:

            source = resolve(packages, package, source)

            if args.verbose:
                print(f'   + {source}')

            if source.startswith('git@'):
                filename = os.path.join(args.tmpdir, f'{package["package"]}-{package["version"]}')

                if not os.path.exists(filename):
                    run_command(f'git clone {source} {filename}')
                else:
                    run_command(f'cd {filename} && git reset --hard && git pull')
            else:
                filename = wget.detect_filename(source)
                filename = os.path.join(args.tmpdir, filename)

                if not os.path.exists(filename):
                    wget.download(source, filename)
                    print('')

                package['archives'].append(filename)

    return packages


def stage_3(packages):

    print('Unpacking packages')

    for package in packages:

        print(f' - Unpacking {package["package"]}:{package["version"]}')

        for archive in package['archives']:
            
            if args.verbose:
                print(f'   + {archive}')

            if archive.endswith('.zip'):
                run_command(f'unzip -o -q {archive} -d {args.tmpdir}')
            else:
                run_command(f'tar xf {archive} -C {args.tmpdir}')

    return packages


def stage_4(packages):

    print('Patching packages')

    for package in packages:

        srcdir = prepare(packages, package, False)
        curdir = os.curdir

        if not 'build' in package:
            continue

        if 'setup' in package['build']:

            print(f' - Setup {package["package"]}:{package["version"]}')

            for cmd in package['build']['setup']:

                cmd = resolve(packages, package, cmd)

                if args.verbose:
                    print(f'   + {cmd}')

                os.chdir(os.path.join(srcdir))
                run_command(f'{cmd} 1> __build/setup.log 2> __build/setup.err')
                os.chdir(curdir)

        print(f' - Patching {package["package"]}:{package["version"]}')

        if 'patches' in package['build']:

            for patch in package['build']['patches']:

                patch = resolve(packages, package, patch)
                patch = os.path.join(package['root'], patch)

                if args.verbose:
                    print(f'   + {patch}')

                os.chdir(os.path.join(srcdir))
                run_command(f'patch -p1 -t --verbose < {patch} 1> __build/patch.log 2> __build/patch.err')
                os.chdir(curdir)


    return packages



def stage_5(packages):

    print('Build packages')

    for package in packages:
        build(packages, package)

    return packages


def stage_6(packages):

    print('Packaging packages')

    for package in packages:

        if not 'build' in package:
            continue

        print(f' - Packaging {package["package"]}:{package["version"]}')

        srcdir = prepare(packages, package, False)
        curdir = os.curdir

        os.chdir(os.path.join(srcdir, '__out'))
    
        if os.path.isdir(f'{package["root"]}/.pkg'):
            run_command(f'cp -R {package["root"]}/.pkg .')
        else:
            run_command(f'mkdir -p .pkg')

        run_command(f'echo {package["version"]} > .pkg/version')
        run_command(f'tar cJf {args.root}/{package["package"]}.tar.xz * .pkg')
        os.chdir(curdir)


def main():

    if not os.path.exists(args.tmpdir):
        os.mkdir(args.tmpdir)

    args.root = os.path.abspath(args.root)

    if args.clean:
        return shutil.rmtree(args.tmpdir)


    packages = []
    packages = stage_1(packages)
    packages = stage_2(packages)
    packages = stage_3(packages)
    packages = stage_4(packages)
    packages = stage_5(packages)
    packages = stage_6(packages)


if __name__ == '__main__':
    main()
   

        