#!/usr/bin/env python3
"""Servidor TCP de deteccao para o cliente Flutter."""

import argparse
import json
import socket
import struct
from pathlib import Path

import cv2
import numpy as np
from ultralytics import YOLO


def receive_exact(connection: socket.socket, size: int) -> bytes:
    data = bytearray()
    while len(data) < size:
        chunk = connection.recv(min(64 * 1024, size - len(data)))
        if not chunk:
            raise ConnectionError("cliente desconectado antes do fim da imagem")
        data.extend(chunk)
    return bytes(data)


def detect_objects(model: YOLO, jpeg: bytes) -> list[dict[str, object]]:
    image = cv2.imdecode(np.frombuffer(jpeg, dtype=np.uint8), cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("imagem JPEG invalida")
    result = model(image, verbose=False)[0]
    return [
        {"label": result.names[int(class_id)], "confidence": round(float(confidence), 3)}
        for class_id, confidence in zip(result.boxes.cls, result.boxes.conf)
    ]


def serve(host: str, port: int, model_path: str) -> None:
    model = YOLO(model_path)
    with socket.create_server((host, port), reuse_port=False) as server:
        print(f"Servidor ouvindo em {host}:{port}")
        while True:
            connection, address = server.accept()
            with connection:
                try:
                    image_size = struct.unpack("!I", receive_exact(connection, 4))[0]
                    if image_size == 0 or image_size > 20 * 1024 * 1024:
                        raise ValueError("tamanho de imagem invalido")
                    objects = detect_objects(model, receive_exact(connection, image_size))
                    response = {"objects": objects}
                except Exception as error:
                    response = {"error": str(error)}
                connection.sendall((json.dumps(response) + "\n").encode("utf-8"))
            print(f"{address[0]} -> {len(response.get('objects', []))} objeto(s)")


if __name__ == "__main__":
    project_directory = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=5000)
    parser.add_argument(
        "--model", default=str(project_directory / "yolo11n.pt")
    )
    args = parser.parse_args()
    serve(args.host, args.port, args.model)