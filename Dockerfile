# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN git clone https://github.com/lldacing/ComfyUI_PuLID_Flux_ll /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll && cd /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll && (git checkout 5f1e91d1d66884dd2b43a6e3e8e0c8a78638fa35 2>/dev/null || (git fetch origin 5f1e91d1d66884dd2b43a6e3e8e0c8a78638fa35 --depth=1 && git checkout 5f1e91d1d66884dd2b43a6e3e8e0c8a78638fa35) || echo "WARN: commit 5f1e91d1d66884dd2b43a6e3e8e0c8a78638fa35 unreachable in https://github.com/lldacing/ComfyUI_PuLID_Flux_ll, falling back to default branch HEAD")
RUN git clone https://github.com/cubiq/ComfyUI_essentials /comfyui/custom_nodes/ComfyUI_essentials && cd /comfyui/custom_nodes/ComfyUI_essentials && (git checkout 33ff89fd354d8ec3ab6affb605a79a931b445d99 2>/dev/null || (git fetch origin 33ff89fd354d8ec3ab6affb605a79a931b445d99 --depth=1 && git checkout 33ff89fd354d8ec3ab6affb605a79a931b445d99) || echo "WARN: commit 33ff89fd354d8ec3ab6affb605a79a931b445d99 unreachable in https://github.com/cubiq/ComfyUI_essentials, falling back to default branch HEAD")
RUN git clone https://github.com/lldacing/ComfyUI_Patches_ll /comfyui/custom_nodes/ComfyUI_Patches_ll && cd /comfyui/custom_nodes/ComfyUI_Patches_ll && (git checkout 314a84dfdde7d4f23693ad0eb7d4e19ebded7392 2>/dev/null || (git fetch origin 314a84dfdde7d4f23693ad0eb7d4e19ebded7392 --depth=1 && git checkout 314a84dfdde7d4f23693ad0eb7d4e19ebded7392) || echo "WARN: commit 314a84dfdde7d4f23693ad0eb7d4e19ebded7392 unreachable in https://github.com/lldacing/ComfyUI_Patches_ll, falling back to default branch HEAD")

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/modelzpalace/ae.safetensors/resolve/main/ae.safetensors?download=true' --relative-path models/vae --filename 'ae.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors' --relative-path models/diffusion_models --filename 'pulid_flux_v0.9.1.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/carlosrozas/ae.safetensors/resolve/main/ae.safetensors?download=true' --relative-path models/text_encoders --filename 't5/t5xxl_fp8_e4m3fn.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors' --relative-path models/text_encoders --filename 'clip_l.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors' --relative-path models/diffusion_models --filename 'flux1-dev-fp8.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/wemo04dq934cynwiy5u3.webp' "https://cool-anteater-319.convex.cloud/api/storage/27aded1e-79cb-4484-a719-e04c48a3a51b"
RUN wget --progress=dot:giga -O '/comfyui/input/dcoxl00bbxn29ilfy3dj.webp' "https://cool-anteater-319.convex.cloud/api/storage/48602a69-f474-4a6a-953a-898a7fc62bca"
