//
//  THEOplayerRCTCacheAPI.swift
//  Theoplayer
//
//  Created by William Van Haevre on 01/08/2023.
//

import Foundation
import UIKit
import THEOplayerSDK

let CACHE_EVENT_PROP_STATUS: String = "status"
let CACHE_EVENT_PROP_PROGRESS: String = "progress"
let CACHE_EVENT_PROP_TASK: String = "task"
let CACHE_EVENT_PROP_TASKS: String = "tasks"

let CACHE_TAG: String = "[CacheAPI]"

@objc(THEOplayerRCTCacheAPI)
class THEOplayerRCTCacheAPI: RCTEventEmitter {
    // MARK: Cache Listeners
    private var cacheStatusListener: EventListener?
    
    // MARK: CacheTask listeners (attached dynamically to new tasks)
    private var taskStateChangeListeners: [String:EventListener] = [:] // key is CacheTask.id
    private var taskProgressListeners: [String:EventListener] = [:] // key is CacheTask.id
    
    override static func moduleName() -> String! {
        return "CacheModule"
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    override func supportedEvents() -> [String]! {
        return [
            "onCacheStatusChange",
            "onAddCachingTaskEvent",
            "onRemoveCachingTaskEvent",
            "onCachingTaskProgressEvent",
            "onCachingTaskStatusChangeEvent"
        ]
    }
    
    override init() {
        super.init()
        
        // attach listeners
        self.attachCacheListeners()
    }
    
    deinit {
        self.detachCacheListeners()
    }
    
    // MARK: - attach/dettach cache Listeners
    private func attachCacheListeners() {
        // STATE_CHANGE
        self.cacheStatusListener = THEOplayer.cache.addEventListener(type: CacheEventTypes.STATE_CHANGE) { [weak self] event in
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] Received STATE_CHANGE event from THEOplayer.cache") }
            self?.sendEvent(withName: "onCacheStatusChange", body: [
                CACHE_EVENT_PROP_STATUS: THEOplayerRCTTypeUtils.cacheStatusToString(THEOplayer.cache.status)
            ])
        }
        if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] StateChange listener attached to THEOplayer.cache") }
        
        // Attach listeners to all task currently known to cache
        for cachingTask in THEOplayer.cache.tasks {
            self.attachTaskListenersToTask(cachingTask)
        }
    }
    
    private func detachCacheListeners() {
        // STATE_CHANGE
        if let cacheStatusListener = self.cacheStatusListener {
            THEOplayer.cache.removeEventListener(type: CacheEventTypes.STATE_CHANGE, listener: cacheStatusListener)
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] StateChange listener dettached from THEOplayer.cache") }
        }
    }
    
    private func attachTaskListenersToTask(_ newTask: CachingTask) {
        // add STATE_CHANGE listeners to newly created task
        self.taskStateChangeListeners[newTask.id] = newTask.addEventListener(type: CachingTaskEventTypes.STATE_CHANGE) { [weak self] event in
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] Received STATE_CHANGE event from task with id \(newTask.id)") }
            self?.sendEvent(withName: "onCachingTaskStatusChangeEvent", body: [
                CACHETASK_PROP_ID: newTask.id,
                CACHE_EVENT_PROP_STATUS: THEOplayerRCTTypeUtils.cachingTaskStatusToString(newTask.status)
            ])
        }
        if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] StateChange listener attached to task with id \(newTask.id).") }
        
        // add PROGRESS listeners to newly created task
        self.taskProgressListeners[newTask.id] = newTask.addEventListener(type: CachingTaskEventTypes.PROGRESS) { [weak self] event in
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] Received PROGRESS event from task with id \(newTask.id)") }
            self?.sendEvent(withName: "onCachingTaskProgressEvent", body: [
                CACHETASK_PROP_ID: newTask.id,
                CACHE_EVENT_PROP_PROGRESS: THEOplayerRCTCacheAggregator.aggregateCacheTaskProgress(task: newTask)
            ] as [String : Any])
        }
        if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] Progress listener attached to task with id \(newTask.id).") }
    }
    
    private func detachTaskListenersFromTask(_ task: CachingTask) {
        // STATE_CHANGE
        if let taskStateChangeListener = self.taskStateChangeListeners[task.id] {
            task.removeEventListener(type: CachingTaskEventTypes.STATE_CHANGE, listener: taskStateChangeListener)
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] StateChange listener dettached from task with id \(task.id)") }
        }
        // PROGRESS
        if let taskProgressListener = self.taskProgressListeners[task.id] {
            task.removeEventListener(type: CachingTaskEventTypes.PROGRESS, listener: taskProgressListener)
            if DEBUG_CACHE_EVENTS { PrintUtils.printLog(logText: "[NATIVE] Progress listener dettached from task with id \(task.id)") }
        }
    }
    
    // MARK: API
    
    @objc(getInitialState:rejecter:)
    func getInitialState(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        resolve([
            CACHE_EVENT_PROP_STATUS: THEOplayerRCTTypeUtils.cacheStatusToString(THEOplayer.cache.status),
            CACHE_EVENT_PROP_TASKS: THEOplayerRCTCacheAggregator.aggregateCacheTasks(tasks: THEOplayer.cache.tasks)
        ] as [String : Any])
    }
    
    @objc(createTask:params:)
    func createTask(_ src: NSDictionary, params: NSDictionary) -> Void {
        if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] createTask triggered on Cache API.") }
        let params = THEOplayerRCTCachingParametersBuilder.buildCachingParameters(params)
        if let srcDescription = THEOplayerRCTSourceDescriptionBuilder.buildSourceDescription(src),
           let newTask = THEOplayer.cache.createTask(source: srcDescription, parameters: params) {
            if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] New cache task created with id \(newTask.id)") }
            
            // emit onAddCachingTaskEvent
            self.sendEvent(withName: "onAddCachingTaskEvent", body: [
                CACHE_EVENT_PROP_TASK: THEOplayerRCTCacheAggregator.aggregateCacheTask(task: newTask)
            ])
            
            // attach the state and progress listeners to the new task
            self.attachTaskListenersToTask(newTask)
        }
    }
    
    @objc(startCachingTask:)
    func startCachingTask(_ id: NSString) -> Void {
        if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] Start task triggered on Cache API for task with id \(id).") }
        if let task = self.taskById(id as String) {
            task.start()
        }
    }
    
    @objc(pauseCachingTask:)
    func pauseCachingTask(_ id: NSString) -> Void {
        if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] Pause task triggered on Cache API for task with id \(id).") }
        if let task = self.taskById(id as String) {
            task.pause()
        }
    }
    
    @objc(removeCachingTask:)
    func removeCachingTask(_ id: NSString) -> Void {
        if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] Remove task triggered on Cache API for task with id \(id).") }
        if let task = self.taskById(id as String) {
            // remove the task
            task.remove()
            // remove the listeners
            self.detachTaskListenersFromTask(task)
        }
    }
    
    @objc(renewLicense:drmConfig:)
    func renewLicense(_ id: NSString, drmConfig: NSDictionary) -> Void {
        if DEBUG_CACHE_API { PrintUtils.printLog(logText: "[NATIVE] Renew license triggered on Cache API for task with id \(id).") }
        if let task = self.taskById(id as String) {
            //let drmConfiguration = THEOplayerRCTSourceDescriptionBuilder.extractDrmConfiguration()
            //task.license.renew()
        }
    }
    
    private func taskById(_ id: String) -> CachingTask? {
        return THEOplayer.cache.tasks.first {
            cachingTask in cachingTask.id == id
        }
    }
}
