/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.viewers.LeafNodesSet;

import java.lang.all;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.set.AbstractObservableSet;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;
import org.eclipse.core.databinding.observable.set.SetDiff;
import org.eclipse.core.internal.databinding.observable.tree.IUnorderedTreeProvider;
import org.eclipse.core.internal.databinding.observable.tree.TreePath;

/**
 * This set consists of all leaf nodes from the given tree (that is, all nodes
 * for which ITreeProvider.createChildSet returns null).
 */
public class LeafNodesSet : AbstractObservableSet {

    private HashSet leafNodes;

    private HashMap mapElementsOntoNodeInfo;

    private IUnorderedTreeProvider tree;

    private Object input;

    private int staleCount = 0;

    private class NodeInfo : IStaleListener, ISetChangeListener {
        // Number of times the element occurs in the tree
        private int count;

        // Element
        private TreePath treePath;

        // Children set (or null if this is a leaf node)
        IObservableSet children;

        private bool wasStale = false;

        /**
         * @param treePath
         */
        public this(TreePath treePath) {
            this.treePath = treePath;
            children = tree.createChildSet(this.treePath);
            if (children !is null) {
                children.addStaleListener(this);
                children.addSetChangeListener(this);
            }
            count = 1;
        }

        public void handleSetChange(SetChangeEvent event) {
            processDiff(treePath, event.diff);
        }

        public void handleStale(StaleEvent event) {
            if (wasStale !is children.isStale()) {
                if (wasStale) {
                    staleCount--;
                } else {
                    staleCount++;
                }
                wasStale = !wasStale;
            }
            setStale(staleCount > 0);
        }

        /**
         * 
         */
        public void dispose() {
            if (children !is null) {
                children.dispose();
                children = null;
                if (wasStale) {
                    staleCount--;
                }
            }
        }
    }

    /**
     * Creates a set that will contain the leaf nodes from the given tree
     * 
     * @param tree
     *            tree whose leaf nodes will be computed
     */
    public this(IUnorderedTreeProvider tree) {
        this(null, tree);
    }

    /**
     * Creates a set that will contain the leaf nodes from the given tree, and
     * sets the root of the tree to the given element.
     * 
     * @param initialInput
     *            root of the tree
     * @param tree
     *            tree whose leaf nodes will be computed
     */
    public this(Object initialInput, IUnorderedTreeProvider tree) {
leafNodes = new HashSet();
mapElementsOntoNodeInfo = new HashMap();
        super(tree.getRealm());
        this.tree = tree;
        if (initialInput !is null) {
            setInput(initialInput);
        }
    }

    private void processDiff(TreePath treePath, SetDiff diff) {
        Set removals = new HashSet();
        HashSet additions = new HashSet();

        for (Iterator iter = diff.getRemovals().iterator(); iter.hasNext();) {
            Object next = iter.next();

            elementRemoved(treePath.createChildPath(next), removals);
        }

        for (Iterator iter = diff.getAdditions().iterator(); iter.hasNext();) {
            Object next = iter.next();

            elementDiscovered(treePath.createChildPath(next), additions);
        }

        HashSet newRemovals = new HashSet();
        newRemovals.addAll(removals);
        newRemovals.removeAll(additions);

        HashSet newAdditions = new HashSet();
        newAdditions.addAll(additions);
        newAdditions.removeAll(removals);

        leafNodes.addAll(newAdditions);
        leafNodes.removeAll(newRemovals);

        if (!newAdditions.isEmpty() || !newRemovals.isEmpty()) {
            setStale(staleCount > 0);
            fireSetChange(Diffs.createSetDiff(newAdditions, newRemovals));
        }
    }

    /**
     * Sets the root of the tree to the given element.
     * 
     * @param input
     *            new root of the tree
     */
    public void setInput(Object input) {
        Set removals = Collections.EMPTY_SET;
        Set additions = Collections.EMPTY_SET;
        if (this.input !is null) {
            removals = Collections.singleton(this.input);
        } else if (input !is null) {
            additions = Collections.singleton(input);
        }
        this.input = input;
        processDiff(TreePath.EMPTY, Diffs.createSetDiff(additions, removals));
    }

    /**
     * Called when an element is removed from the tree. The given HashSet will
     * be filled in with all removed leaf nodes.
     * 
     * @param treePath
     * @param removals
     */
    private void elementRemoved(TreePath treePath, Set removals) {
        NodeInfo newNode = cast(NodeInfo) mapElementsOntoNodeInfo.get(treePath);

        if (newNode !is null) {
            newNode = new NodeInfo(treePath);
            newNode.count--;
            if (newNode.count is 0) {
                mapElementsOntoNodeInfo.remove(treePath);
                if (newNode.children !is null) {
                    for (Iterator iter = newNode.children.iterator(); iter
                            .hasNext();) {
                        Object next = iter.next();

                        elementRemoved(treePath.createChildPath(next), removals);
                    }
                    newNode.children.dispose();
                } else {
                    removals.add(treePath);
                }
            }
        }
    }

    /**
     * Called when a new element is discovered in the tree. The given HashSet
     * will be filled in with all newly discovered leaf nodes.
     * 
     * @param treePath
     * @param additions
     */
    private void elementDiscovered(TreePath treePath, HashSet additions) {
        NodeInfo newNode = cast(NodeInfo) mapElementsOntoNodeInfo.get(treePath);

        if (newNode is null) {
            newNode = new NodeInfo(treePath);
            mapElementsOntoNodeInfo.put(treePath, newNode);
            if (newNode.children !is null) {
                for (Iterator iter = newNode.children.iterator(); iter
                        .hasNext();) {
                    Object next = iter.next();

                    elementDiscovered(treePath.createChildPath(next), additions);
                }
            } else {
                additions.add(treePath);
            }
        } else {
            // If this node was already known, increment the reference count.
            newNode.count++;
        }
    }

    protected Set getWrappedSet() {
        return leafNodes;
    }

    public Object getElementType() {
        return Object.classinfo;
    }

    public void dispose() {
        for (Iterator iter = mapElementsOntoNodeInfo.values().iterator(); iter
                .hasNext();) {
            NodeInfo next = cast(NodeInfo) iter.next();

            if (next.children !is null) {
                next.dispose();
            }
        }

        mapElementsOntoNodeInfo.clear();
        leafNodes.clear();
        super.dispose();
    }
}
