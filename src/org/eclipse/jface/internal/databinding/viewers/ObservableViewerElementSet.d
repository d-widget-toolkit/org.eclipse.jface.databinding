/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 215531)
 *     Matthew Hall - bug 230267
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ObservableViewerElementSet;
import org.eclipse.jface.internal.databinding.viewers.ViewerElementSet;

import java.lang.all;

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.set.AbstractObservableSet;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.WritableSet;
import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.viewers.IElementComparer;
import org.eclipse.jface.viewers.StructuredViewer;

/**
 * An {@link IObservableSet} of elements in a {@link StructuredViewer}.
 * Elements of the set are compared using an {@link IElementComparer} instead of
 * {@link #equals(Object)}.
 * <p>
 * This class is <i>not</i> a strict implementation the {@link IObservableSet}
 * interface. It intentionally violates the {@link Set} contract, which requires
 * the use of {@link #equals(Object)} when comparing elements. This class is
 * designed for use with {@link StructuredViewer} which uses
 * {@link IElementComparer} for element comparisons.
 * 
 * 
 * @since 1.2
 */
public class ObservableViewerElementSet : AbstractObservableSet {
    private Set wrappedSet;
    private Object elementType;
    private IElementComparer comparer;

    /**
     * Constructs an ObservableViewerElementSet on the given {@link Realm} which
     * uses the given {@link IElementComparer} to compare elements.
     * 
     * @param realm
     *            the realm of the constructed set.
     * @param elementType
     *            the element type of the constructed set.
     * @param comparer
     *            the {@link IElementComparer} used to compare elements.
     */
    public this(Realm realm, Object elementType,
            IElementComparer comparer) {
        super(realm);

        Assert.isNotNull(cast(Object)comparer);
        this.wrappedSet = new ViewerElementSet(comparer);
        this.elementType = elementType;
        this.comparer = comparer;
    }

    protected Set getWrappedSet() {
        return wrappedSet;
    }

    public Object getElementType() {
        return elementType;
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = wrappedSet.iterator();
        return new class() Iterator {
            Object last;

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
                fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET,
                        Collections.singleton(last)));
            }
        };
    }

    public bool add(Object o) {
        getterCalled();
        bool changed = wrappedSet.add(o);
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.singleton(o),
                    Collections.EMPTY_SET));
        return changed;
    }

    public bool addAll(Collection c) {
        getterCalled();
        Set additions = new ViewerElementSet(comparer);
        for (Iterator iterator = c.iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            if (wrappedSet.add(element))
                additions.add(element);
        }
        bool changed = !additions.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(additions, Collections.EMPTY_SET));
        return changed;
    }

    public bool remove(Object o) {
        getterCalled();
        bool changed = wrappedSet.remove(o);
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET,
                    Collections.singleton(o)));
        return changed;
    }

    public bool removeAll(Collection c) {
        getterCalled();
        Set removals = new ViewerElementSet(comparer);
        for (Iterator iterator = c.iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            if (wrappedSet.remove(element))
                removals.add(element);
        }
        bool changed = !removals.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET, removals));
        return changed;
    }

    public bool retainAll(Collection c) {
        getterCalled();
        Set removals = new ViewerElementSet(comparer);
        Object[] toRetain = c.toArray();
        outer: for (Iterator iterator = wrappedSet.iterator(); iterator
                .hasNext();) {
            Object element = iterator.next();
            // Cannot rely on c.contains(element) because we must compare
            // elements using IElementComparer.
            for (int i = 0; i < toRetain.length; i++) {
                if (comparer.opEquals(element, toRetain[i]))
                    continue outer;
            }
            iterator.remove();
            removals.add(element);
        }
        bool changed = !removals.isEmpty();
        if (changed)
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET, removals));
        return changed;
    }

    public void clear() {
        getterCalled();
        if (!wrappedSet.isEmpty()) {
            Set removals = wrappedSet;
            wrappedSet = new ViewerElementSet(comparer);
            fireSetChange(Diffs.createSetDiff(Collections.EMPTY_SET, removals));
        }
    }

    /**
     * Returns an {@link IObservableSet} for holding viewer elements, using the
     * given {@link IElementComparer} for comparisons.
     * 
     * @param realm
     *            the realm of the returned observable
     * @param elementType
     *            the element type of the returned set
     * @param comparer
     *            the element comparer to use in element comparisons (may be
     *            null). If null, the returned set will compare elements
     *            according to the standard contract for {@link Set} interface
     *            contract.
     * @return a Set for holding viewer elements, using the given
     *         {@link IElementComparer} for comparisons.
     */
    public static IObservableSet withComparer(Realm realm, Object elementType,
            IElementComparer comparer) {
        if (comparer is null)
            return new WritableSet(realm, Collections.EMPTY_SET, elementType);
        return new ObservableViewerElementSet(realm, elementType, comparer);
    }
}
