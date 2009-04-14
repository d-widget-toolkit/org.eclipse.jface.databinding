/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 215531)
 *     Matthew Hall - bug 124684
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ViewerElementSet;

import java.lang.all;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.viewers.IElementComparer;
import org.eclipse.jface.viewers.StructuredViewer;

/**
 * A {@link Set} of elements in a {@link StructuredViewer}. Elements of the set
 * are compared using an {@link IElementComparer} instead of
 * {@link #equals(Object)}.
 * <p>
 * This class is <i>not</i> a strict implementation the {@link Set} interface.
 * It intentionally violates the {@link Set} contract, which requires the use of
 * {@link #equals(Object)} when comparing elements. This class is designed for
 * use with {@link StructuredViewer} which uses {@link IElementComparer} for
 * element comparisons.
 * 
 * @since 1.2
 */
public class ViewerElementSet : Set {
    private final Set wrappedSet;
    private final IElementComparer comparer;

    /**
     * Constructs a ViewerElementSet using the given {@link IElementComparer}.
     * 
     * @param comparer
     *            the {@link IElementComparer} used for comparing elements.
     */
    public this(IElementComparer comparer) {
        Assert.isNotNull(comparer);
        this.wrappedSet = new HashSet();
        this.comparer = comparer;
    }

    /**
     * Constructs a ViewerElementSet containing all the elements in the
     * specified collection.
     * 
     * @param collection
     *            the collection whose elements are to be added to this set.
     * @param comparer
     *            the {@link IElementComparer} used for comparing elements.
     */
    public this(Collection collection, IElementComparer comparer) {
        this(comparer);
        addAll(collection);
    }

    public bool add(Object o) {
        return wrappedSet.add(new ViewerElementWrapper(o, comparer));
    }

    public bool addAll(Collection c) {
        bool changed = false;
        for (Iterator iterator = c.iterator(); iterator.hasNext();)
            changed |= wrappedSet.add(new ViewerElementWrapper(iterator.next(),
                    comparer));
        return changed;
    }

    public void clear() {
        wrappedSet.clear();
    }

    public bool contains(Object o) {
        return wrappedSet.contains(new ViewerElementWrapper(o, comparer));
    }

    public bool containsAll(Collection c) {
        for (Iterator iterator = c.iterator(); iterator.hasNext();)
            if (!wrappedSet.contains(new ViewerElementWrapper(iterator.next(),
                    comparer)))
                return false;
        return true;
    }

    public bool isEmpty() {
        return wrappedSet.isEmpty();
    }

    public Iterator iterator() {
        final Iterator wrappedIterator = wrappedSet.iterator();
        return new class() Iterator {
            public bool hasNext() {
                return wrappedIterator.hasNext();
            }

            public Object next() {
                return (cast(ViewerElementWrapper) wrappedIterator.next()).unwrap();
            }

            public void remove() {
                wrappedIterator.remove();
            }
        };
    }

    public bool remove(Object o) {
        return wrappedSet.remove(new ViewerElementWrapper(o, comparer));
    }

    public bool removeAll(Collection c) {
        bool changed = false;
        for (Iterator iterator = c.iterator(); iterator.hasNext();)
            changed |= remove(iterator.next());
        return changed;
    }

    public bool retainAll(Collection c) {
        // Have to do this the slow way to ensure correct comparisons. i.e.
        // cannot delegate to c.contains(it) since we can't be sure will
        // compare elements the way we want.
        bool changed = false;
        Object[] retainAll = c.toArray();
        outer: for (Iterator iterator = iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            for (int i = 0; i < retainAll.length; i++) {
                if (comparer.equals(element, retainAll[i])) {
                    continue outer;
                }
            }
            iterator.remove();
            changed = true;
        }
        return changed;
    }

    public int size() {
        return wrappedSet.size();
    }

    public Object[] toArray() {
        return toArray(new Object[wrappedSet.size()]);
    }

    public Object[] toArray(Object[] a) {
        int size = wrappedSet.size();
        ViewerElementWrapper[] wrappedArray = cast(ViewerElementWrapper[]) wrappedSet
                .toArray(new ViewerElementWrapper[size]);
        Object[] result = a;
        if (a.length < size) {
            result = cast(Object[]) Array.newInstance(a.getClass()
                    .getComponentType(), size);
        }
        for (int i = 0; i < size; i++)
            result[i] = wrappedArray[i].unwrap();
        return result;
    }

    public bool equals(Object obj) {
        if (obj is this)
            return true;
        if (!(null !is cast(Set)obj))
            return false;
        Set that = cast(Set) obj;
        return size() is that.size() && containsAll(that);
    }

    public int hashCode() {
        int hash = 0;
        for (Iterator iterator = iterator(); iterator.hasNext();) {
            Object element = iterator.next();
            hash += element is null ? 0 : element.hashCode();
        }
        return hash;
    }

    /**
     * Returns a Set for holding viewer elements, using the given
     * {@link IElementComparer} for comparisons.
     * 
     * @param comparer
     *            the element comparer to use in element comparisons. If null,
     *            the returned set will compare elements according to the
     *            standard contract for {@link Set} interface contract.
     * @return a Set for holding viewer elements, using the given
     *         {@link IElementComparer} for comparisons.
     */
    public static Set withComparer(IElementComparer comparer) {
        if (comparer is null)
            return new HashSet();
        return new ViewerElementSet(comparer);
    }
}
