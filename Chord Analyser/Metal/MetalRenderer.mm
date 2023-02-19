//
//  Example.m
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

// metal-cpp
#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

#import <MetalKit/MetalKit.hpp>
#include "MetalRenderer.hpp"

class Renderer {
public:
    Renderer( MTL::Device* pDevice );
    ~Renderer();
    void draw( MTK::View* pView );
    
private:
    MTL::Device* _pDevice;
    MTL::CommandQueue* _pCommandQueue;
};

#pragma mark - Renderer

Renderer::Renderer( MTL::Device* pDevice ) : _pDevice( pDevice->retain() ) {
    _pCommandQueue = _pDevice->newCommandQueue();
}

Renderer::~Renderer() {
    _pCommandQueue->release();
    _pDevice->release();
}

void Renderer::draw( MTK::View* pView ) {
    NS::AutoreleasePool* pPool = NS::AutoreleasePool::alloc()->init();
    
    MTL::RenderPassDescriptor* pRenderPassDescriptor = pView->currentRenderPassDescriptor();
    MTL::CommandBuffer* pCommandBuffer = _pCommandQueue->commandBuffer();
    
    MTL::RenderCommandEncoder* pCommandEncoder = pCommandBuffer->renderCommandEncoder(pRenderPassDescriptor);
    pCommandEncoder->endEncoding();
    
    pCommandBuffer->presentDrawable( pView->currentDrawable() );
    pCommandBuffer->commit();
    
    pPool->release();
}
