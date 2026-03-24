#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import urlopen


BASE_URL = "https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/arm64"
PACKAGE_FILES = (
	"containerd.io_1.7.27-1_arm64.deb",
	"docker-buildx-plugin_0.27.0-1~ubuntu.24.04~noble_arm64.deb",
	"docker-ce-cli_28.4.0-1~ubuntu.24.04~noble_arm64.deb",
	"docker-ce_28.4.0-1~ubuntu.24.04~noble_arm64.deb",
	"docker-compose-plugin_2.39.2-1~ubuntu.24.04~noble_arm64.deb",
)
CHUNK_SIZE = 1024 * 1024


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		description="Download the Docker .deb packages required by FENRIR_1.0.0."
	)
	parser.add_argument(
		"--output-dir",
		type=Path,
		default=Path(__file__).resolve().parent,
		help="Directory to write the downloaded packages to.",
	)
	parser.add_argument(
		"--force",
		action="store_true",
		help="Overwrite files that already exist.",
	)
	parser.add_argument(
		"--timeout",
		type=float,
		default=60.0,
		help="Network timeout in seconds for each file download.",
	)
	return parser.parse_args()


def download_file(url: str, destination: Path, timeout: float) -> None:
	with urlopen(url, timeout=timeout) as response:
		with destination.open("wb") as output_file:
			while True:
				chunk = response.read(CHUNK_SIZE)
				if not chunk:
					break
				output_file.write(chunk)


def main() -> int:
	args = parse_args()
	output_dir = args.output_dir.resolve()
	output_dir.mkdir(parents=True, exist_ok=True)

	failed_downloads: list[str] = []

	for package_file in PACKAGE_FILES:
		destination = output_dir / package_file
		if destination.exists() and not args.force:
			print(f"Skipping existing file: {destination.name}")
			continue

		url = f"{BASE_URL}/{package_file}"
		temp_destination = destination.with_suffix(destination.suffix + ".part")
		if temp_destination.exists():
			temp_destination.unlink()

		print(f"Downloading {package_file}")
		try:
			download_file(url, temp_destination, args.timeout)
			temp_destination.replace(destination)
		except (HTTPError, URLError, TimeoutError, OSError) as error:
			if temp_destination.exists():
				temp_destination.unlink()
			failed_downloads.append(package_file)
			print(f"Failed to download {package_file}: {error}", file=sys.stderr)

	if failed_downloads:
		print(
			"The following packages could not be downloaded:\n"
			+ "\n".join(f"- {package_file}" for package_file in failed_downloads),
			file=sys.stderr,
		)
		return 1

	print(f"Docker packages are available in: {output_dir}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
