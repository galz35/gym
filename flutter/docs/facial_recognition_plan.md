# Facial Recognition System Architecture Plan

## 1. Overview
This document outlines the implementation of an **Edge AI based Facial Recognition System** for gym access control. The system prioritizes **privacy**, **offline capability**, and **performance** by performing facial detection and embedding generation directly on the client device (Flutter). The backend (Supabase) is used only for storing vector embeddings and performing similarity searches via `pgvector`.

## 2. Architecture & Components

### 2.1 Technology Stack
- **Frontend**: Flutter (Dart)
- **AI/ML (On-Device)**: 
  - `google_mlkit_face_detection` (Face Detection)
  - `tflite_flutter` (State-of-the-art MobileFaceNet model for embeddings)
  - `image` (Image processing)
- **Backend**: Supabase (PostgreSQL)
  - `pgvector` extension for vector similarity search.
  - RPC function `match_face_embedding` for 1:N matching.
  - Supabase Storage for compressed user photos.

### 2.2 Data Flow

**A. User Registration (Enrollment)**
1. **App**: User captures a selfie via `BiometricRegistrationScreen`.
2. **App (FaceRecognitionService)**: 
   - Detects the largest face using ML Kit.
   - Crops and aligns the face.
   - Normalizes the image (112x112).
   - Generates a 192-dimensional vector embedding using MobileFaceNet.
3. **App (ImageService)**: Compresses the original image to WebP format.
4. **App (ImageService)**: Uploads the WebP image to Supabase Storage (`/clientes/{id}`).
5. **App (ClientesProvider)**: Sends the vector embedding + photo URL to Supabase Database (`cliente` table).

**B. User Identification (Access Control)**
1. **App**: User approaches kiosk/device. Camera captures frame.
2. **App**: Detects face and generates embedding (same as above).
3. **App (ClientesProvider)**: Calls Supabase RPC `match_face_embedding` with the query vector.
4. **Supabase**: Performs cosine similarity search against stored vectors. Returns matches with similarity > threshold (e.g., 0.6).
5. **App**: If a high-confidence match is found, retrieves the user profile and grants access (logs attendance).

## 3. Implementation Details

### 3.1 Database Schema (Supabase)
- **Table**: `cliente`
  - `id`: UUID (Primary Key)
  - `face_embedding`: `vector(192)` (Enabled via pgvector)
  - `foto_url`: Text (URL to Supabase Storage)
  - ... other fields (nombre, estado, etc.)

- **Function**: `match_face_embedding`
  - Input: `query_embedding vector(192)`, `match_threshold float`, `match_count int`
  - Logic: `SELECT ... ORDER BY face_embedding <=> query_embedding LIMIT match_count`

### 3.2 Services
- **FaceRecognitionService**: Core engine. Handles TensorFlow Lite interpreter, ML Kit integration, and YUV/Image conversion.
- **ImageService**: Utilities for image compression (WebP) and Supabase Storage uploads.
- **ClientesProvider**: State management. Orchestrates the flow between UI, Services, and Data layer.

## 4. Security & Privacy
- **Processing**: Face data is processed locally. Images are only uploaded if the user consents to profile photo storage.
- **Storage**: Embeddings are mathematical representations, not actual images.
- **Access**: Row Level Security (RLS) on Supabase ensures only authorized staff/systems can query or update biometric data.

## 5. Next Steps
- **Performance Tuning**: Adjust the matching threshold (currently 0.6) based on real-world testing.
- **Liveness Detection**: Implement a "blink" or "smile" check to prevent photo-spoofing attacks (future phase).
- **Offline Sync**: Cache embeddings locally for completely offline verification (optional, for syncing multiple devices).
