/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 124684)
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.CheckableCheckedElementsObservableSet;
import org.eclipse.jface.internal.databinding.viewers.ViewerElementSet;

import java.lang.all;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.set.AbstractObservableSet;
import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.viewers.CheckStateChangedEvent;
import org.eclipse.jface.viewers.ICheckStateListener;
import org.eclipse.jface.viewers.ICheckable;

/**
 * 
 * @since 1.2
 */
public class CheckableCheckedElementsObservableSet :
        AbstractObservableSet {
    private ICheckable checkable;
    private Set wrappedSet;
    private Object elementType;
    private ICheckStateListener listener;

    /**
     * Constructs a new instance on the given realm and checkable.
     * 
     * @param realm
     *            the observable's realm
     * @param checkable
     *            the ICheckable to track
     * @param elementType
     *            type of elements in the set
     */
    public this(Realm realm,
            ICheckable checkable, Object elementType) {
        this(realm, checkable, elementType, new HashSet());
    }

    /**
     * Constructs a new instance of the given realm, and checkable,
     * 
     * @param realm
     *            the observable's realm
     * @param checkable
     *            the ICheckable to track
     * @param elementType
     *            type of elements in the set
     * @param wrappedSet
     *            the set being wrapped
     */
    public this(Realm realm,
            ICheckable checkable, Object elementType, Set wrappedSet) {
        super(realm);
        Assert.isNotNull(cast(Object)checkable, "Checkable cannot be null"); //$NON-NLS-1$
        Assert.isNotNull(cast(Object)wrappedSet, "Wrapped set cannot be null"); //$NON-NLS-1$
        this.checkable = checkable;
        this.wrappedSet = wrappedSet;
        this.elementType = elementType;

        listener = new class(wrappedSet) ICheckStateListener {
            Set wrappedSet_;
            this(Set s){ wrappedSet_ = wrappedSet;}
            public void checkStateChanged(CheckStateChangedEvent event) {
                Object element = event.getElement();
                if (event.getChecked()) {
                    if (wrappedSet_.add(element))
                        fireSetChange(Diffs.createSetDiff(Collections
                                .singleton(element), Collections.EMPTY_SET));
                } else {
                    if (wrappedSet_.remove(element))
                        fireSetChange(Diffs.createSetDiff(
                                Collections.EMPTY_SET, Collections
                                        .singleton(element)));
                }
            }
        };
        checkable.addCheckStateListener(listener);
    }

    protected Set getWrappedSet() {
        return wrappedSet;
    }

    Set createDiffSet() {
        return new HashSet();
    }

    public Object getElementType() {
        return elementType;
    }

    public bool add(String o) {
        return add(stringcast(o));
    }
    public bool add(Object o) {
        getterCalled();
        bool added = wrappedSet.add(o);
        if (added) {
            checkable.setChecked(o, true);
            fireSetChange(Diffs.createSetDiff(Collections.singleton(o),
                    Collections.EMPTY_SET));
        }
        return added;
    }

    alias AbstractObservableSet.remove remove;
    public bool remove(String o) {
        return remove(stringcast(o));
    }
    public bool remove(Object o) {
        getterCalled();
        bool removed = wrappedSet.remove(o);
        if (removed) {
            checkable.setChecked(o, false);
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET,
                    Collections.singleton(o)));
        }
        return removed;
    }

    public bool addAll(Collection c) {
        getterCalled();
        Set additions = createDiffSet();
        for (Iterator iterator = c.iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            if (wrappedSet.add(element)) {
                checkable.setChecked(element, true);
                additions.add(element);
            }
        }
        bool changed = !additions.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(additions, Collections.EMPTY_SET));
        return changed;
    }

    public bool removeAll(Collection c) {
        getterCalled();
        Set removals = createDiffSet();
        for (Iterator iterator = c.iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            if (wrappedSet.remove(element)) {
                checkable.setChecked(element, false);
                removals.add(element);
            }
        }
        bool changed = !removals.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET, removals));
        return changed;
    }

    public bool retainAll(Collection c) {
        getterCalled();

        // To ensure that elements are compared correctly, e.g. ViewerElementSet
        Set toRetain = createDiffSet();
        toRetain.addAll(c);

        Set removals = createDiffSet();
        for (Iterator iterator = wrappedSet.iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            if (!toRetain.contains(element)) {
                iterator.remove();
                checkable.setChecked(element, false);
                removals.add(element);
            }
        }
        bool changed = !removals.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET, removals));
        return changed;
    }

    public void clear() {
        removeAll(wrappedSet);
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = wrappedSet.iterator();
        return new class() Iterator {
            private Object last = null;

            public bool hasNext() {
                getterCalled();
                return wrappedIterator.hasNext();
            }

            public Object next() {
                getterCalled();
                return last = wrappedIterator.next();
            }

            public void remove() {
                getterCalled();
                wrappedIterator.remove();
                checkable.setChecked(last, false);
                fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET,
                        Collections.singleton(last)));
            }
        };
    }

    public synchronized void dispose() {
        if (checkable !is null) {
            checkable.removeCheckStateListener(listener);
            checkable = null;
            listener = null;
        }
        super.dispose();
    }
}
